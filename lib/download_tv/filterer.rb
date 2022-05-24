# frozen_string_literal: true

module DownloadTV
  ##
  # Builds and applies filters to the results
  class Filterer
    def initialize(filters_config)
      @filters = []
      build_filters(filters_config)
    end

    ##
    # Iteratively applies filters until they've all been applied
    # or applying the next filter would result in no results
    def filter(shows)
      # shows is tuple (show name, link)
      @filters.each do |f|
        new_shows = shows.reject { |name, _link| f.call(name) }
        # Go to next filter if the filter removes every release
        next if new_shows.empty?

        shows = new_shows
      end

      shows
    end

    private

    def build_filters(filters_config)
      return unless filters_config

      filters_config[:includes].map { |i| build_include_filter(i) }
      filters_config[:excludes].map { |i| build_exclude_filter(i) }
    end

    def build_include_filter(str)
      @filters << ->(n) { !n.upcase.include?(str) }
    end

    def build_exclude_filter(str)
      @filters << ->(n) { n.upcase.include?(str) }
    end
  end
end
