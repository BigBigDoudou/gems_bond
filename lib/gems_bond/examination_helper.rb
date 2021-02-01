# frozen_string_literal: true

module GemsBond
  # Examines gem sanity
  module ExaminationHelper
    SCORES = YAML.safe_load(File.read(File.join(File.dirname(__FILE__), "scores.yml")))
    BOUNDARIES = SCORES["boundaries"]
    RESULTS = SCORES["results"]

    def version_gap
      memoize(:version_gap) { calculate_version_gap }
    end

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

    def soften(value, comparison)
      # returns a shaped curve
      sigmoid = ->(x) { 1 / (1 + Math.exp(-x * 10)) }
      # simoid boundaries are [0.5, 1]
      #   so remove 0.5 and multiply by 2 to have boundaries [0, 1]
      (sigmoid.call(value / comparison) - 0.5) * 2
    end

    # --- COMPUTE

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

    # --- VERSION STATUS

    def calculate_version_gap
      return unless version && versions

      index = versions.index { |v| v[:number] == version }
      return unless index

      gap = versions[0..index].count { |v| !v[:prerelease] } - 1
      gap.positive? ? gap : 0
    end
  end
end
