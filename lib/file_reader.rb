class FileReader
  attr_reader :path

  def initialize(path)
    @path = path
  end

  def read_file
    input = File.read(@path)
  end
end
