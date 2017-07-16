require 'client'

describe Client do
  context "connecting to Zendesk api" do
    it "connects without an error" do
      VCR.use_cassette("ticket results") do
        client = Client.new
        result = client.all_data
        expect(result.keys).to include("tickets")
        expect(result.keys).to include("next_page")
        expect(result.keys).to include("count")
        expect(result["tickets"].first.keys).to include("id")
        expect(result["tickets"].first.keys).to include("requester_id")
        expect(result["tickets"].size).to be == result["count"]
      end
    end
  end
end
