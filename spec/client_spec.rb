require 'client'

describe Client do
  describe "with an explicit cassette name" do
    context "an http request without errors" do
      VCR.use_cassette("ticket results") do
        client = Client.new
        tickets = client.all_tickets
        ticket_count = client.ticket_count

        it "records an array of tickets" do
          expect(tickets).to be_an_instance_of Array
        end

        it "records with correct ticket keys" do
          expect(tickets.first.keys).to include("id", "requester_id", "subject", "description", "created_at")
        end

        it "records with correct ticket count" do
          expect(tickets.length).to eq ticket_count
        end
      end
    end
  end
end
