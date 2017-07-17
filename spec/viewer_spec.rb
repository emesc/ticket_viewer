require "viewer"

describe Viewer do
  let(:viewer) { Viewer.new }

  describe "#connect" do
    it "prints out an opening message" do
      allow(Readline).to receive(:readline).and_return('quit')
      expect{ viewer.connect }.to output(/Welcome/).to_stdout
    end
  end

  describe "#do_command" do
    context "with quit command" do
      it "prints out a closing message and exits" do
        allow(Readline).to receive(:readline).and_return('quit')
        expect{ viewer.connect }.to output(/Goodbye/).to_stdout
      end
    end
  end
end
