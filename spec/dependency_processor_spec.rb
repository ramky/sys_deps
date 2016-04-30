require 'spec_helper'

FIXTURE_PATH = '/Users/riyer/temp/sys_deps/spec/fixtures/input.txt'
describe DependencyProcessor do
  describe '#process' do
    it 'processes each line at a time'
    it 'checks the size of each item'
    it "checks the line size doesn't exceed 80"

    it 'processes the file' do
      dp = DependencyProcessor.new(FIXTURE_PATH)
      dp.process

      expect(dp.process).to eq nil
    end
  end
end
