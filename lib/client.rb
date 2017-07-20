require "http"
require "addressable"
require "date"

class Client
  attr_accessor :ticket_count
  def paginate_through(filename)
    page = 1
    per_page = 25
    start_time = Date.new(2017, 1, 1).to_time.to_i

    next_page = ""
    @ticket_count = 0
    result = []

    while !next_page.nil?
      response = get(filename, { start_time: start_time, page: page, per_page: per_page })
      result << response["tickets"]
      next_page = response["next_page"]
      @ticket_count = response["count"]
      page += 1
    end
    result
  end

  def all_tickets
    paginate_through("tickets.json")
  end

  private
    def subdomain
      "emesc"
    end

    def email
      "em@curlycoder.me"
    end

    def password
      "mPuHma8XKa6bJvzw"
    end

    def zendesk_url(filename, params={})
      Addressable::URI.new({
        scheme:       "https",
        host:         "#{subdomain}.zendesk.com",
        path:         File.join("api", "v2", filename),
        query_values: params
      })
    end

    def get(filename, params={})
      HTTP.basic_auth(user: email, pass: password).get(zendesk_url(filename, params)).parse
    end
end

