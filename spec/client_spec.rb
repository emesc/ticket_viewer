require 'client'

describe Client do
  describe "with an explicit cassette name" do
    context "an http request without errors" do
      VCR.use_cassette("tickets") do
        client = Client.new
        tickets = client.all_tickets
        ticket_count = client.ticket_count

        it "records an array of tickets" do
          expect(tickets).to be_an_instance_of Array
        end

        it "records with correct ticket keys" do
          expect(tickets[0][0].keys).to include("id", "requester_id", "subject", "description", "created_at")
        end

        it "records with correct ticket count" do
          tickets_total = tickets.inject(0) { |len, t| len + t.length }
          expect(tickets_total).to eq ticket_count
        end
      end
    end
  end
end
