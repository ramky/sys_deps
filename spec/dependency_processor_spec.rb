require 'spec_helper'

describe DependencyProcessor do
  let(:dp) { DependencyProcessor.new(fixture_path) }

  describe '#process' do
    it 'processes each line at a time'
    it 'checks the size of each item'
    it "checks the line size doesn't exceed 80"

    context 'DEPEND action' do
      it 'sets the dependencies' do
        allow(dp).to receive(:read_file).
          and_return("DEPEND   TELNET TCPIP NETCARD\nDEPEND TCPIP NETCARD")

        dp.process

        expected = {"TELNET"=>["TCPIP", "NETCARD"], "TCPIP"=>["NETCARD"]}
        expect(dp.dependencies).to eq expected
      end
    end

    context 'INSTALL action' do
      it 'sets output for a single item' do
        allow(dp).to receive(:read_file).
          and_return("DEPEND   TELNET TCPIP NETCARD\nDEPEND TCPIP NETCARD\nINSTALL NETCARD")

        dp.process

        expect(dp.output).to eq [
          "DEPEND TELNET TCPIP NETCARD\n",
          "DEPEND TCPIP NETCARD\n",
          "INSTALL NETCARD\n  Installing NETCARD\n"
        ]
      end

      it 'sets output for nested dependencies' do
        allow(dp).to receive(:read_file).
          and_return("DEPEND   TELNET TCPIP NETCARD\nDEPEND TCPIP NETCARD\nINSTALL TELNET")

        dp.process

        expect(dp.output).to eq [
          "DEPEND TELNET TCPIP NETCARD\n",
          "DEPEND TCPIP NETCARD\n",
          "INSTALL TELNET\n  Installing TCPIP\n  Installing NETCARD\n  Installing TELNET\n"
        ]
      end

      it 'sets output for already installed item' do
        allow(dp).to receive(:read_file).
          and_return("DEPEND   TELNET TCPIP NETCARD\nDEPEND TCPIP NETCARD\nINSTALL NETCARD\nINSTALL NETCARD\n")

        dp.process

        expect(dp.output).to eq [
          "DEPEND TELNET TCPIP NETCARD\n",
          "DEPEND TCPIP NETCARD\n",
          "INSTALL NETCARD\n  Installing NETCARD\n",
          "INSTALL NETCARD\n  NETCARD is already installed\n"
        ]
      end
    end

    context 'REMOVE action' do
      it 'removes a single item if there are no dependencies' do
        allow(dp).to receive(:read_file).
          and_return("INSTALL NETCARD\nREMOVE NETCARD")

        dp.process

        expect(dp.output).to eq [
          "INSTALL NETCARD\n  Installing NETCARD\n",
          "REMOVE NETCARD\n  Removing NETCARD\n"
        ]
      end

      it 'removes a nested structure if there are no dependencies' do
        allow(dp).to receive(:read_file).
          and_return("DEPEND   TELNET TCPIP NETCARD\nINSTALL TELNET\nREMOVE TELNET")

        dp.process

        expect(dp.output).to eq [
          "DEPEND TELNET TCPIP NETCARD\n",
          "INSTALL TELNET\n  Installing TCPIP\n  Installing NETCARD\n  Installing TELNET\n",
          "REMOVE TELNET\n  Removing TELNET\n  Removing TCPIP\n  Removing NETCARD\n"
        ]
      end

      it 'does not remove if there are dependencies' do
        allow(dp).to receive(:read_file).
          and_return("DEPEND   TELNET TCPIP NETCARD\nDEPEND TCPIP NETCARD\nINSTALL NETCARD\nREMOVE NETCARD")

        dp.process

        expect(dp.output).to eq [
          "DEPEND TELNET TCPIP NETCARD\n",
          "DEPEND TCPIP NETCARD\n",
          "INSTALL NETCARD\n  Installing NETCARD\n",
          "REMOVE NETCARD\n  NETCARD is still needed\n"
        ]
      end
    end

    it 'processes the file' do
      dp.process

      expect(dp.output).to eq  [
        "DEPEND TELNET TCPIP NETCARD\n",
        "DEPEND TCPIP NETCARD\n",
        "DEPEND DNS TCPIP NETCARD\n",
        "DEPEND BROWSER TCPIP HTML\n",
        "INSTALL NETCARD\n  Installing NETCARD\n",
        "INSTALL TELNET\n  Installing TCPIP\n  Installing TELNET\n",
        "INSTALL foo\n  Installing foo\n",
        "REMOVE NETCARD\n  NETCARD is still needed\n",
        "INSTALL BROWSER\n  Installing HTML\n  Installing BROWSER\n",
        "INSTALL DNS\n  Installing DNS\n",
        "LIST\n  NETCARD\n  TCPIP\n  TELNET\n  foo\n  HTML\n  BROWSER\n  DNS\n",
        "REMOVE TELNET\n  Removing TELNET\n",
        "REMOVE NETCARD\n  NETCARD is still needed\n",
        "REMOVE DNS\n  Removing DNS\n",
        "REMOVE NETCARD\n  NETCARD is still needed\n",
        "INSTALL NETCARD\n  NETCARD is already installed\n",
        "REMOVE TCPIP\n  TCPIP is still needed\n",
        "REMOVE BROWSER\n  Removing BROWSER\n  Removing TCPIP\n  Removing HTML\n",
        "REMOVE TCPIP\n  TCPIP is not installed\n",
        "LIST\n  NETCARD\n  foo\n",
        "END\n"
      ]
    end
  end
end
