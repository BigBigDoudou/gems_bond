# frozen_string_literal: true

module GemsBond
  # Examines gem sanity
  module ExaminationHelper
    SCORES = YAML.safe_load(File.read(File.join(File.dirname(__FILE__), "scores.yml")))
    BOUNDARIES = SCORES["boundaries"]
    RESULTS = SCORES["results"]

    # Returns gap between installed and last released version, in days
    # @return [Integer, nil] (memoized)
    def version_gap
      memoize(:version_gap) { calculate_version_gap }
    end

    # @!method activity_score
    # Returns activity score
    # @return [Integer, nil] in [0, 1] (memoized)

    # @!method popularity_score
    # Returns popularity score
    # @return [Integer, nil] in [0, 1] (memoized)

    # @!method average_score
    # Returns average score
    # @return [Integer, nil] in [0, 1] (memoized)
    RESULTS.each do |result, values|
      define_method("#{result}_score") do
        memoize("#{result}_score") do
          weighted_average(
            values.map do |key, weighting|
              [__send__("#{key}_score"), weighting]
            end
          )
        end
      end
    end

    private

    # Scores getters and calculation

    # For each inspected data, generate two methods:
    # - <data>_score that memoizes the calculated score
    # - calculate_<data>_score that calculates the score and returns [Integer, nil] in [0, 1]
    BOUNDARIES.each_key do |key|
      # create a _score getter for each key
      define_method("#{key}_score") do
        instance_variable_get("@#{key}_score") if instance_variable_defined?("@#{key}_score")

        instance_variable_set("@#{key}_score", __send__("calculate_#{key}_score"))
      end

      # create a calculation method for each key
      define_method("calculate_#{key}_score") do
        value = public_send(key)
        return unless value

        min = BOUNDARIES[key]["min"]
        max = BOUNDARIES[key]["max"]

        # when lower the better (last commit at...)
        if min
          threshold = Float(BOUNDARIES[key]["threshold"] || 0)
          return Float(1) if value <= threshold
          return Float(0) if value >= min

          soften(min - Float(value) + threshold, min + threshold)

        # when higher the better (downloads count...)
        else
          return Float(1) if value >= max
          return Float(0) if value <= 1

          soften(Float(value), max)
        end
      end
    end

    # Returns a score with a logarithmic approach
    # @param value [Float] the value for inspected data
    # @param comparison [Numeric] the value giving the maximal score (1)
    # @returns [Float]
    # @example
    #   soften(10.to_f,100.to_f) #=> 0.46
    # The idea is that a gem with half as much stars
    #   than rails gem (which is very high and stands for comparison here)
    #   should get a very high score but still be behind rails itself
    def soften(value, comparison)
      # returns a shaped curve
      sigmoid = ->(x) { 1 / (1 + Math.exp(-x * 10)) }
      # simoid boundaries are [0.5, 1]
      #   so remove 0.5 and multiply by 2 to have boundaries [0, 1]
      (sigmoid.call(value / comparison) - 0.5) * 2
    end

    # Returns an average after including weight for each value
    # @param scores [Array<Array<Float, Integer>>] each hash looks like [value, weight]
    # @returns [Float]
    # @example
    #   weighted_average([[4.0, 2], [1.0, 3]]) #=> 2.2
    def weighted_average(scores)
      acc = 0
      weight = 0
      scores.each do |score|
        value, weighting = score
        next unless value

        acc += value * weighting
        weight += weighting
      end.compact
      return if weight.zero?

      acc / weight
    end

    # Returns gap between installed and last released version, in days
    # @return [Integer, nil]
    def calculate_version_gap
      return unless version && versions

      index = versions.index { |v| v[:number] == version }
      return unless index

      gap = versions[0..index].count { |v| !v[:prerelease] } - 1
      gap.positive? ? gap : 0
    end
  end
end
