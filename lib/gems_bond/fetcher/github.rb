# frozen_string_literal: true

require "octokit"

module GemsBond
  module Fetcher
    # Fetches data from GitHub
    class Github
      REPOSITORY_REGEX = %r{https?://github.com/(?<repository>.*/.*)}.freeze

      class << self
        def valid_url?(url)
          url&.match?(REPOSITORY_REGEX)
        end
      end

      def initialize(url)
        @url = url
      end

      def source
        "github"
      end

      def start
        parse_url
        login
        set_repository
        self
      rescue Octokit::Unauthorized, Octokit::InvalidRepository, Octokit::NotFound
        nil
      end

      def forks_count
        @repository["forks"]
      end

      def stars_count
        @repository["watchers"]
      end

      def contributors_count
        client = Octokit::Client.new(access_token: token, per_page: 1)
        client.contributors(@repository_path)
        response = client.last_response
        links = response.headers[:link]
        return 0 unless links

        Integer(links.match(/.*page=(?<last>\d+)>; rel="last"/)[:last], 10)
      end

      def open_issues_count
        @repository["open_issues"]
      end

      def last_commit_date
        date = client.commits(@repository_path).first[:commit][:committer][:date]
        return unless date

        Date.parse(date.to_s)
      end

      def days_since_last_commit
        return unless last_commit_date

        Date.today - last_commit_date
      end

      def lib_size
        contents_size = dir_size("lib")
        return unless contents_size

        lines_count_estimation = contents_size / 25
        return lines_count_estimation if lines_count_estimation < 100

        lines_count_estimation - lines_count_estimation % 100
      end

      private

      def parse_url
        matches = @url.match(REPOSITORY_REGEX)
        raise Octokit::InvalidRepository unless matches

        path = matches[:repository].split("/")
        @repository_path = "#{path[0]}/#{path[1]}"
      end

      def login
        @login ||= client.user.login
      end

      def client
        Octokit::Client.new(access_token: token)
      end

      def token
        GemsBond.configuration&.github_token
      end

      def set_repository
        @repository = client.repo(@repository_path)
      end

      def dir_size(dir_path)
        contents = client.contents(@repository_path, path: dir_path)
        acc =
          contents
          .select { |content| content[:type] == "file" }
          .sum { |content| content[:size] }
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
