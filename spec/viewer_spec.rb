require "viewer"

describe Viewer do
  let(:viewer) { Viewer.new }

  describe "valid commands from the user" do
    context "with tickets from #load" do
      VCR.use_cassette("tickets") do
        vcr_viewer = Viewer.new
        tickets = vcr_viewer.load

        it "returns an api response with the correct objects" do
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

    context "with tickets from #next" do
      VCR.use_cassette("tickets") do
        vcr_viewer = Viewer.new
        vcr_viewer.load
        output = capture_stdout { vcr_viewer.next }
        rows = output.split("\n")

        it "outputs the next page of tickets on a table format" do
          expect(rows[0]).to match(/Showing page 2/)
          expect(rows[1]).to match(/Type 'menu' to view options or 'quit' to exit/)
          expect(rows[2]).to eq("-" * 135)
          expect(rows[3]).to match(/^\s{2}ID\s|\sStatus\s{4}|\sSubject\s{54}|\sRequester\s{6}|\sCreated\son\s{21}$/)
          expect(rows[4]).to eq("-" * 135)
          expect(rows[5]).to include("|    26 |")
        end

        it "outputs a maximum of 25 tickets" do
          expect(rows.length).to be <= 57 # 6->table headers + 25->tickets + 25->dividers + 1->option
        end
      end
    end

    context "with #prev" do
      VCR.use_cassette("tickets") do
        vcr_viewer = Viewer.new
        vcr_viewer.load
        output = capture_stdout { vcr_viewer.prev }
        rows = output.split("\n")

        it "outputs the previous page of tickets on a table format" do
          expect(rows[0]).to match(/Showing page 5/)
          expect(rows[1]).to match(/Type 'menu' to view options or 'quit' to exit/)
          expect(rows[2]).to eq("-" * 135)
          expect(rows[3]).to match(/^\s{2}ID\s|\sStatus\s{4}|\sSubject\s{54}|\sRequester\s{6}|\sCreated\son\s{21}$/)
          expect(rows[4]).to eq("-" * 135)
          expect(rows[5]).to include("|   101 |")
        end

        it "outputs a maximum of 25 tickets" do
          expect(rows.length).to be <= 57 # 6->table headers + 25->tickets + 25->dividers + 1->option
        end
      end
    end

    context "with #page" do
      VCR.use_cassette("tickets") do
        vcr_viewer = Viewer.new
        vcr_viewer.load

        context "with a valid page request" do
          output = capture_stdout { vcr_viewer.page(3) }
          rows = output.split("\n")

          it "outputs a user specified page on a table format" do
            expect(rows[0]).to match(/Showing page 3/)
            expect(rows[1]).to match(/Type 'menu' to view options or 'quit' to exit/)
            expect(rows[2]).to eq("-" * 135)
            expect(rows[3]).to match(/^\s{2}ID\s|\sStatus\s{4}|\sSubject\s{54}|\sRequester\s{6}|\sCreated\son\s{21}$/)
            expect(rows[4]).to eq("-" * 135)
            expect(rows[5]).to include("|    51 |")
          end

          it "outputs a maximum of 25 tickets" do
            expect(rows.length).to be <= 57 # 6->table headers + 25->tickets + 25->dividers + 1->option
          end
        end

        it "does not output a page for invalid page requests" do
          [-1, 0, 6].each do |i|
            output = capture_stdout { vcr_viewer.page(i) }
            rows = output.split("\n")
            expect(rows[0]).to match(/Ticket\/page not found/)
            expect(rows.length).to be == 1
          end
        end
      end
    end

    context "with #show" do
      VCR.use_cassette("tickets") do
        vcr_viewer = Viewer.new
        vcr_viewer.load

        it "outputs a ticket with for a valid id request" do
          output = capture_stdout { vcr_viewer.show(1)}
          rows = output.split("\n")
          expect(rows[0]).to match(/Showing ticket ID 1/)
          expect(rows[1]).to eq("-" * 135)
          expect(rows[2]).to match(/^\s{2}ID\s|\sStatus\s{4}|\sSubject\s{54}|\sRequester\s{6}|\sCreated\son\s{21}$/)
          expect(rows[3]).to eq("-" * 135)
          expect(rows[4]).to include("|     1 |")
          expect(rows[5]).to eq("-" * 135)
          expect(rows[6]).to match(/PRIORITY/)
          expect(rows[7]).to match(/DESCRIPTION/)
          expect(rows.last).to match(/Type 'menu' to view options or 'quit' to exit/)
        end

        it "does not output a ticket for invalid id requests" do
          [-1, 0, 102].each do |i|
            output = capture_stdout { vcr_viewer.show(i) }
            rows = output.split("\n")
            expect(rows[0]).to match(/Ticket\/page not found/)
            expect(rows.length).to be == 1
          end
        end
      end
    end
  end
end
