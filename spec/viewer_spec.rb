require "viewer"

describe Viewer do
  let(:viewer) { Viewer.new }

  describe "#connect" do
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

    context "with next command" do
      VCR.use_cassette("tickets") do
        vcr_viewer = Viewer.new
        output = capture_stdout { vcr_viewer.connect }

        it "outputs the next list of tickets" do
          fake_user_input("next", "quit")
          tickets = output.split("\n")
          expect(tickets[4]).to match(/Showing page 1/)
          expect(tickets[5]).to match(/Type 'menu' to view options or 'quit' to exit/)
          expect(tickets[6]).to eq("-" * 120)
          expect(tickets[7]).to match(/^\s{2}ID\s|\sSubject\s{54}|\sRequester\s{6}|\sCreated\son\s{21}$/)
          expect(tickets[8]).to eq("-" * 120)
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
