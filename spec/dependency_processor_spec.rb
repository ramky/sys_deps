require 'spec_helper'

describe DependencyProcessor do
  describe '#process' do
    it 'processes each line at a time'
    it 'checks the size of each item'
    it "checks the line size doesn't exceed 80"

    it 'processes the file' do
      dp = DependencyProcessor.new(fixture_path)

      expect(dp.process).to eq [
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
        "LIST\n  NETCARD\n  TCPIP\n  TELNET\n  foo\n  HTML\n  BROWSER\n  DNS",
        "REMOVE TELNET\n  Removing TELNET\n",
        "REMOVE NETCARD\n  NETCARD is still needed\n",
        "REMOVE DNS\n  Removing DNS\n",
        "REMOVE NETCARD\n  NETCARD is still needed\n",
        "INSTALL NETCARD\n  NETCARD is already installed\n",
        "REMOVE TCPIP\n  TCPIP is still needed\n",
        "REMOVE BROWSER\n  Removing BROWSER\n  Removing TCPIP\n  Removing HTML\n",
        "REMOVE TCPIP\n  TCPIP is not installed\n",
        "LIST\n  NETCARD\n  foo",
        "END\n"
      ]
    end
  end
end
