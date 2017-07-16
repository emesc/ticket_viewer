require 'client'

describe Client do
  describe "with an explicit cassette name" do
    context "an http request without errors" do
      VCR.use_cassette("ticket results") do
        client = Client.new
        result = client.all_data

        it "records with the correct response keys" do
          expect(result.keys).to match_array(["tickets", "next_page", "previous_page", "count"])
        end

        it "records with the correct ticket keys" do
          expect(result["tickets"].first.keys).to include("id", "requester_id")
        end

        it "records with the correct ticket count" do
          expect(result["tickets"].size).to be == result["count"]
        end
      end
    end
  end
end
