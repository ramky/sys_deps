class DependencyProcessor
  attr_reader :input, :output

  def initialize(path)
    reader = FileReader.new(path)
    @input = reader.read_file
    @hash = {}
    @output = []
    @installed_items = {}
  end

  def process
    input.lines.each do |line|
      process_line(line)
    end
    @output
  end

  def process_line(line)
    line = line.strip
    action, *items = line.split(/\s+/)

    # TODO: cleanup with objects - single responsibility principle
    case action
    when 'DEPEND'
      add_dependency(items)
    when 'INSTALL'
      install(items.first)
    when 'REMOVE'
      remove(items.first)
    when 'LIST'
      list
    when 'END'
      #NOOP
    end
  end

  def add_dependency(items)
    depends_on = items.slice(1, items.length)
    @hash[items.first] = depends_on
    output_text = 'DEPEND ' + items.join(' ') + "\n"
    @output << output_text
  end

  def install(item)
    output_text = "INSTALL #{item}\n"
    # should refactor to a method
    if @hash.has_key?(item)
        @hash[item].each do |it|
          next if @installed_items.has_key?(it) # clean this up?
          output_text += "\t Installing #{it}\n"
          @installed_items[it] = 1
        end
    end
    output_text += "\t Installing #{item}\n"
    @installed_items[item] = 1
    @output << output_text
  end

  def remove(item)
    output_text = "REMOVE #{item}\n"
    unless okay_to_remove?(item)
      output_text += "\t #{item} is still needed\n"
    else
      output_text += "\t Removing #{item}\n"
      # should refactor to a method
      if @hash.has_key?(item)
        @hash[item].each do |it|
          output_text += "\t Removing #{it}\n"
        end
        @hash.delete(item)
      end
    end
    @output << output_text
  end

  def list
    output_text = "LIST\n"
    output_text += @hash.keys.join("\n")
    @output << output_text
  end

  def okay_to_remove?(item)
    okay = true
    @hash.values.each do |dependency|
      if dependency.include?(item)
        okay = false
        break
      end
    end
    okay
  end
end
