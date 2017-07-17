require "viewer"

describe Viewer do
  let(:viewer) { Viewer.new }

  describe "#connect" do
    it "outputs an opening message" do
      fake_user_input("quit")
      expect{ viewer.connect }.to output(/Welcome/).to_stdout
    end
  end

  describe "#do_command" do
    context "with menu command" do
      it "outputs a list of valid commands" do
        fake_user_input("menu", "quit")
        output = capture_stdout { viewer.connect }
        expect(output).to include("*Type 'next'      to view the next page of tickets")
      end
    end

    context "with quit command" do
      it "outputs a closing message and exits" do
        fake_user_input("quit")
        expect{ viewer.connect }.to output(/Goodbye/).to_stdout
      end
    end
  end
end
