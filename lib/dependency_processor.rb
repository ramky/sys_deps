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
      add_to_output('END')
    end
  end

  def add_to_output(message)
    output_text = message + "\n"
    @output << output_text
  end

  def add_dependency(items)
    depends_on = items.slice(1, items.length)
    @hash[items.first] = depends_on
    output_text = 'DEPEND ' + items.join(' ') + "\n"
    @output << output_text
  end

  def install(item)
    output_text = "INSTALL #{item}\n"
    if already_installed?(item)
      output_text  += "  #{item} is already installed\n"
      @output << output_text
      return
    end
    # should refactor to a method
    if @hash.has_key?(item)
        @hash[item].each do |it|
          output_text += "  Installing #{it}\n" unless already_installed?(it)
          mark_as_installed(it)
        end
    end
    output_text += "  Installing #{item}\n"
    mark_as_installed(item)
    @output << output_text
  end

  def mark_as_installed(item)
    @installed_items[item] = (
      @installed_items[item].nil? ? 1 : @installed_items[item] + 1
    )
  end

  def mark_as_uninstalled(item)
    if @installed_items.has_key?(item)
      if @installed_items[item] > 1
        @installed_items[item] = @installed_items[item] - 1
      elsif @installed_items[item] == 1
        @installed_items.delete(item)
      end
    end
  end

  def remove(item)
    output_text = "REMOVE #{item}\n"

    unless @installed_items.has_key?(item)
      output_text += "  #{item} is not installed\n"
      @output << output_text
      return
    end

    unless okay_to_remove?(item)
      output_text += "  #{item} is still needed\n"
    else
      output_text += "  Removing #{item}\n"
      # should refactor to a method
      if @hash.has_key?(item)
        @hash[item].each do |it|
          if @installed_items[it] == 1
            output_text += "  Removing #{it}\n"
          end
          mark_as_uninstalled(it)
        end
        @hash.delete(item)
        mark_as_uninstalled(item)
      end
    end
    @output << output_text
  end

  def list
    output_text = "LIST\n  "
    output_text += @installed_items.keys.join("\n  ")
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

  def already_installed?(item)
    @installed_items.has_key?(item)
  end
end
