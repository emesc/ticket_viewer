require "viewer"

describe Viewer do
  let(:viewer) { Viewer.new }

  describe "#connect" do
    it "prints out an opening greeting" do
      allow(Readline).to receive(:readline).and_return('quit')
      expect{ viewer.connect }.to output(/Welcome/).to_stdout
    end
  end
end
