require "open-uri"
require "pp"
require "json"

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

  def get(filepath)
    open("https://#{subdomain}.zendesk.com/api/v2/#{filepath}", http_basic_authentication: [email, password]).read
  end

  def all_data
    JSON.parse(get("tickets.json"))
  end
end
