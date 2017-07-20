require "viewer"

describe Viewer do
  let(:viewer) { Viewer.new }

  describe "#launch" do
    it "outputs an opening message" do
      fake_user_input("quit")
      expect{ viewer.launch }.to output(/Welcome/).to_stdout
    end
  end

  describe "#do_command" do
    context "with menu command" do
      it "outputs a list of valid commands" do
        fake_user_input("menu", "quit")
        expect { viewer.launch }.to output(/\*Type 'load'      to connect to the api and retrieve the tickets/).to_stdout
      end
    end

    context "with quit command" do
      it "outputs a closing message and exits" do
        fake_user_input("quit")
        expect{ viewer.launch }.to output(/Goodbye/).to_stdout
      end
    end
  end
end
