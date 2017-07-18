require "viewer"

describe Viewer do
  let(:viewer) { Viewer.new }

  describe "#load" do
    it "outputs an opening message" do
      fake_user_input("quit")
      expect{ viewer.introduction }.to output(/Welcome/).to_stdout
    end
  end

  describe "#do_command" do
    context "with menu command" do
      it "outputs a list of valid commands" do
        fake_user_input("menu", "quit")
        output = capture_stdout{ viewer.menu }
        expect(output).to include("*Type 'next'      to view the next page of tickets")
      end
    end

    context "with load command" do
      VCR.use_cassette("tickets") do
        vcr_viewer = Viewer.new
        tickets = vcr_viewer.load
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

        xit "outputs the first page of tickets" do
          fake_user_input("load", "quit")
          output = capture_stdout { tickets }
          rows = output.split("\n")
          expect(rows[3]).to match(/Showing page 1/)
          # expect(rows[2]).to match(/Type 'menu' to view options or 'quit' to exit/)
          # expect(rows[3]).to eq("-" * 135)
          # expect(rows[4]).to match(/^\s{2}ID\s|\sSubject\s{54}|\sRequester\s{6}|\sCreated\son\s{21}$/)
          # expect(rows[5]).to eq("-" * 135)
          # expect(rows[6]).to include("|     1 |")
          expect(rows.length).to be <= 57 # 6->table headers + 25->tickets + 25->dividers + 1->option
        end
      end
    end

    context "with next command" do
      VCR.use_cassette("tickets") do
        vcr_viewer = Viewer.new
        vcr_viewer.load

        it "outputs the next page of tickets" do
          fake_user_input("next", "quit")
          output = capture_stdout { vcr_viewer.next_page }
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
        vcr_viewer.load

        it "outputs the previous page of tickets" do
          fake_user_input("prev", "quit")
          output = capture_stdout { vcr_viewer.prev_page }
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
        vcr_viewer.load

        it "outputs a user specified page" do
          fake_user_input("page 3", "quit")
          output = capture_stdout { vcr_viewer.page(3) }
          rows = output.split("\n")
          expect(rows[0]).to match(/Showing page 3/)
          expect(rows[1]).to match(/Type 'menu' to view options or 'quit' to exit/)
          expect(rows[2]).to eq("-" * 135)
          expect(rows[3]).to match(/^\s{2}ID\s|\sStatus\s{4}|\sSubject\s{54}|\sRequester\s{6}|\sCreated\son\s{21}$/)
          expect(rows[4]).to eq("-" * 135)
          expect(rows[5]).to include("|    51 |")
          expect(rows.length).to be <= 57 # 6->table headers + 25->tickets + 25->dividers + 1->option
        end
      end
    end

    context "with show command" do
      VCR.use_cassette("tickets") do
        vcr_viewer = Viewer.new
        vcr_viewer.load

        it "outputs a ticket with the requested id" do
          fake_user_input("show 1", "quit")
          output = capture_stdout { vcr_viewer.show(1)}
          rows = output.split("\n")
          expect(rows[0]).to match(/Showing ticket ID 1/)
          expect(rows[1]).to eq("-" * 135)
          expect(rows[2]).to match(/^\s{2}ID\s|\sStatus\s{4}|\sSubject\s{54}|\sRequester\s{6}|\sCreated\son\s{21}$/)
          expect(rows[3]).to eq("-" * 135)
          expect(rows[4]).to include("|     1 |")
        end
      end
    end

    context "with quit command" do
      it "outputs a closing message and exits" do
        fake_user_input("quit")
        expect{ viewer.conclusion }.to output(/Goodbye/).to_stdout
      end
    end
  end
end
