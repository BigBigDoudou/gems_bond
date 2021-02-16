# frozen_string_literal: true

require "octokit"
require "gems_bond/fetchers/fetcher"

module GemsBond
  module Fetchers
    # Fetches data from GitHub
    class Github < Fetcher
      # GitHub repository pattern, e.g.: "https://github.com/BigBigDoudou/gems_bond"
      REPOSITORY_REGEX = %r{https?://github.com/(?<repository>.*/.*)}.freeze

      class << self
        # Validates that `url` matches GitHub repository URL
        def valid_url?(url)
          url&.match?(REPOSITORY_REGEX)
        end
      end

      # Initializes an instance
      # @param url [String] URL of the GitHub repository
      # @return [GemsBond::Fetchers::Github]
      def initialize(url)
        super(url)
        @url = url
      end

      # Starts the service and returns self
      # @return [GemsBond::Fetchers::Github, nil]
      # @note rescue connection errors with nil
      def start
        parse_url
        login
        # ensure repository exists (otherwise it raises Octokit error)
        set_repository
        self
      rescue Octokit::Unauthorized, Octokit::InvalidRepository, Octokit::NotFound
        nil
      end

      # Returns number of forks
      # @return [Integer]
      def forks_count
        @repository["forks"]
      end

      # Returns number of stars
      # @return [Integer]
      def stars_count
        @repository["watchers"]
      end

      # Returns number of contributors
      # @return [Integer]
      # @note GitHub API does not provide this number out of the box
      #   so we fetch all repository contributors and paginate with 1 per page
      #   thus the last page (from headers) should equal the number of contributors
      def contributors_count
        client = Octokit::Client.new(access_token: token, per_page: 1)
        client.contributors(@repository_path)
        response = client.last_response
        links = response.headers[:link]
        # e.g.:  "[...] <https://api.github.com/repositories/8514/contributors?per_page=1&page=377>; rel=\"last\""
        return 0 unless links

        Integer(links.match(/.*per_page=1&page=(?<last>\d+)>; rel="last"/)[:last], 10)
      end

      # Returns number of open issues
      # @return [Integer]
      def open_issues_count
        @repository["open_issues"]
      end

      # Returns date of last commit (on main branch)
      # @return [Date]
      def last_commit_date
        date = client.commits(@repository_path).first[:commit][:committer][:date]
        return unless date

        Date.parse(date.to_s)
      end

      # Returns number of days since last commit
      # @return [Date]
      def days_since_last_commit
        return unless last_commit_date

        Date.today - last_commit_date
      end

      # Returns size of the lib directory
      # @return [Integer]
      def lib_size
        contents_size = dir_size("lib")
        return unless contents_size

        lines_count_estimation = contents_size / 25
        return lines_count_estimation if lines_count_estimation < 100

        lines_count_estimation - lines_count_estimation % 100
      end

      private

      # Parses url to find out repository path
      # @return [String]
      # @raise Octokit::InvalidRepository if the url pattern is invalid
      def parse_url
        matches = @url.match(REPOSITORY_REGEX)
        raise Octokit::InvalidRepository unless matches

        path = matches[:repository].split("/")
        @repository_path = "#{path[0]}/#{path[1]}"
      end

      # Logs with client
      # @return [String] GitHub'username
      def login
        @login ||= client.user.login
      end

      # Initializes a client
      # @return [Octokit::Client]
      def client
        Octokit::Client.new(access_token: token)
      end

      # Returns token from configuration
      # @return [String, nil]
      def token
        GemsBond.configuration&.github_token
      end

      # Returns repository object
      # @return [Sawyer::Resource]
      def set_repository
        @repository = client.repo(@repository_path)
      end

      # Returns size of the given directory
      # @param dir_path [String] path to the directory, e.g.: "lib/devise/strategies"
      # @return [Integer]
      # @note sum size of each subdirectories recursively
      def dir_size(dir_path)
        contents = client.contents(@repository_path, path: dir_path)
        # starts accumulator with size of files
        acc =
          contents
          .select { |content| content[:type] == "file" }
          .sum { |content| content[:size] }
        # adds size of subdirectories to the accumulator, with recursion
        acc +=
          contents
          .select { |content| content[:type] == "dir" }
          .sum { |sub_dir| dir_size("#{dir_path}/#{sub_dir[:name]}") }
        acc
      rescue Octokit::NotFound
        nil
      end
    end
  end
end
