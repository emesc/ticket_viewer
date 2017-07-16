require "http"
require "addressable"
require "date"

class Client
  def subdomain
    ENV.fetch("ZENDESK_SUBDOMAIN")
  end

  def email
    ENV.fetch("ZENDESK_EMAIL")
  end

  def password
    ENV.fetch("ZENDESK_PASSWORD")
  end

  def get(filename, params={})
    HTTP.basic_auth(user: email, pass: password).get(zendesk_url(filename, params)).parse
  end

  def zendesk_url(filename, params={})
    Addressable::URI.new({
      scheme:       "https",
      host:         "#{subdomain}.zendesk.com",
      path:         File.join("api", "v2", filename),
      query_values: params
    })
  end

  def all_data
    get("tickets.json", start_time: Date.new(2017, 1, 1).to_time.to_i)
  end
end
