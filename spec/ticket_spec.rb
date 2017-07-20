require "ticket"
require "viewer"

describe Ticket do
  context "with tickets from load command" do
    VCR.use_cassette("tickets") do
      vcr_viewer = Viewer.new

      # vcr_ticket = Ticket.new
      tickets = vcr_viewer.load
      tickets_flat = tickets.flatten

      it "returns api response with the correct objects" do
        expect(tickets).to       be_an_instance_of Array
        expect(tickets[0]).to    be_an_instance_of Array
        expect(tickets[0][0]).to be_an_instance_of Hash
      end

      it "retrieves the first ticket page with the correct keys" do
        expect(tickets[0][0].keys).to include("id", "subject", "requester_id", "description", "created_at")
      end

      it "returns maximum of 25 tickets for each ticket page" do
        tickets.each do |ticket|
          expect(ticket.length).to be <= 25
        end
      end
    end
  end

  context "with next command" do
    VCR.use_cassette("tickets") do
      vcr_viewer = Viewer.new
      tickets = vcr_viewer.load
      vcr_ticket = Ticket.new

      it "outputs the next page of tickets" do
        output = capture_stdout { vcr_ticket.next_page }
        rows = output.split("\n")
        expect(rows[0]).to match(/Showing page 2/)
        expect(rows[1]).to match(/Type 'menu' to view options or 'quit' to exit/)
        expect(rows[2]).to eq("-" * 135)
        expect(rows[3]).to match(/^\s{2}ID\s|\sStatus\s{4}|\sSubject\s{54}|\sRequester\s{6}|\sCreated\son\s{21}$/)
        expect(rows[4]).to eq("-" * 135)
        expect(rows[5]).to include("|    26 |")
        expect(rows.length).to be <= 57 # 6->table headers + 25->tickets + 25->dividers + 1->option
      end
    end
  end

  context "with prev command" do
    VCR.use_cassette("tickets") do
      vcr_viewer = Viewer.new
      tickets = vcr_viewer.load
      vcr_ticket = Ticket.new

      it "outputs the previous page of tickets" do
        output = capture_stdout { vcr_ticket.prev_page }
        rows = output.split("\n")
        expect(rows[0]).to match(/Showing page 5/)
        expect(rows[1]).to match(/Type 'menu' to view options or 'quit' to exit/)
        expect(rows[2]).to eq("-" * 135)
        expect(rows[3]).to match(/^\s{2}ID\s|\sStatus\s{4}|\sSubject\s{54}|\sRequester\s{6}|\sCreated\son\s{21}$/)
        expect(rows[4]).to eq("-" * 135)
        expect(rows[5]).to include("|   101 |")
        expect(rows.length).to be <= 57 # 6->table headers + 25->tickets + 25->dividers + 1->option
      end
    end
  end

  context "with page command" do
    VCR.use_cassette("tickets") do
      vcr_viewer = Viewer.new
      tickets = vcr_viewer.load
      vcr_ticket = Ticket.new

      it "outputs a user specified page" do
        output = capture_stdout { vcr_ticket.page(3) }
        rows = output.split("\n")
        expect(rows[0]).to match(/Showing page 3/)
        expect(rows[1]).to match(/Type 'menu' to view options or 'quit' to exit/)
        expect(rows[2]).to eq("-" * 135)
        expect(rows[3]).to match(/^\s{2}ID\s|\sStatus\s{4}|\sSubject\s{54}|\sRequester\s{6}|\sCreated\son\s{21}$/)
        expect(rows[4]).to eq("-" * 135)
        expect(rows[5]).to include("|    51 |")
        expect(rows.length).to be <= 57 # 6->table headers + 25->tickets + 25->dividers + 1->option
      end

      it "does not output a table for requests outside the number of pages returned" do
        [-1, 0, 6].each do |i|
          output = capture_stdout { vcr_ticket.page(i) }
          rows = output.split("\n")
          expect(rows[0]).to match(/Please enter page number between/)
          expect(rows.length).to be == 1
        end
      end
    end
  end

  context "with show command" do
    VCR.use_cassette("tickets") do
      vcr_viewer = Viewer.new
      tickets = vcr_viewer.load
      vcr_ticket = Ticket.new

      it "outputs a ticket with the requested id" do
        output = capture_stdout { vcr_ticket.show(1)}
        rows = output.split("\n")
        expect(rows[0]).to match(/Showing ticket ID 1/)
        expect(rows[1]).to eq("-" * 135)
        expect(rows[2]).to match(/^\s{2}ID\s|\sStatus\s{4}|\sSubject\s{54}|\sRequester\s{6}|\sCreated\son\s{21}$/)
        expect(rows[3]).to eq("-" * 135)
        expect(rows[4]).to include("|     1 |")
      end

      it "does not output a table for requests outside the number of tickets returned" do
        [-1, 0, 102].each do |i|
          output = capture_stdout { vcr_ticket.show(i) }
          rows = output.split("\n")
          expect(rows[0]).to match(/Ticket not found/)
          expect(rows.length).to be == 1
        end
      end
    end
  end
end
