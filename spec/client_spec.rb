require 'client'

describe Client do
  context "connecting to Zendesk api" do
    it "connects without an error" do
      VCR.user_cassette("ticket results") do
        client = Client.new(25)
        result = client.all_tickets
        expect(result.keys).to include("id")
        expect(result.keys).to include("requester_id")
        expect(result.keys).to include("subject")
        expect(result.keys).to include("description")
        expect(result.keys).to include("created_at")
        expect(result.size).to be == 25
      end
    end
  end
end
