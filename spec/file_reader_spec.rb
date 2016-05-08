require 'spec_helper'

describe FileReader do
  let(:reader) { FileReader.new(fixture_path)  }

  describe '#read_file' do
    it 'reads the file contents' do
      input = reader.read_file

      expect(input).to eq  <<-EOF
DEPEND   TELNET TCPIP NETCARD
DEPEND TCPIP NETCARD
DEPEND DNS TCPIP NETCARD
DEPEND  BROWSER   TCPIP  HTML
INSTALL NETCARD
INSTALL TELNET
INSTALL foo
REMOVE NETCARD
INSTALL BROWSER
INSTALL DNS
LIST
REMOVE TELNET
REMOVE NETCARD
REMOVE DNS
REMOVE NETCARD
INSTALL NETCARD
REMOVE TCPIP
REMOVE BROWSER
REMOVE TCPIP
LIST
END
EOF
    end
  end
end
