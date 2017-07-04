module Linkedin
  class Analytics < Linkedin::Service
    def updates_analytics(page, from_timestamp, to_timestamp: DateTime.now.to_time.to_i)
      from_timestamp_in_mills = from_timestamp * 1000
      to_timestamp_in_mills = to_timestamp * 1000
      fields = '(time,like-count,impression-count,share-count,comment-count)'
      result = get(
        "companies/#{page.fetch('id')}/historical-status-update-statistics:#{fields}",
        'time-granularity': 'day',
        'start-timestamp': from_timestamp_in_mills,
        'end-timestamp': to_timestamp_in_mills
      )
      StatusUpdateParser.parse_status_updates(result)
    end
  end
end
