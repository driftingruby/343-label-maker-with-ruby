require 'net/http'
class Twitter
  USER_ID = ENV["USER_ID"]
  BEARER_TOKEN = ENV["BEARER_TOKEN"]

  def self.fetch
    new.fetch
  end

  def fetch
    Rails.logger.info "Fetching tweets #{Time.current}"

    return if tweets['data'].nil?
    tweets['data'].reverse.each do |tweet|
      user = tweets.dig('includes', 'users').find { |u| u['id'] == tweet['author_id'] }
      record = Tweet.find_or_create_by(
        tweet_id: tweet['id'],
        tweeted_at: tweet['created_at'],
        username: user['name'],
        content: tweet['text']
      )
      next if record.printed?
      Printer.new(record.id).print
    end
  end

  private

  def tweets
    @tweets ||= begin
      uri = URI(url)
      request = Net::HTTP::Get.new(uri)
      request["Authorization"] = "Bearer #{BEARER_TOKEN}"
      response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
        http.request(request)
      end
      JSON.parse(response.body)
    end
  end

  def url
    params = []
    params << "tweet.fields=created_at"
    params << "expansions=author_id"
    params << "since_id=#{last_tweet_id}" if last_tweet_id
    "https://api.twitter.com/2/users/#{USER_ID}/mentions?#{params.join("&")}"
  end

  def last_tweet_id
    @last_tweet_id ||= Tweet.order(tweet_id: :desc).first&.tweet_id
  end
end