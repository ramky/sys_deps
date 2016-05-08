require_relative './file_reader'
require_relative './dependency'

class DependencyProcessor
  attr_reader :reader, :input, :output, :dependencies

  def initialize(path)
    @reader = FileReader.new(path)
    @dependencies = Dependency.new
    @output = []
    @installed_items = Dependency.new
  end

  def read_file
    reader.read_file
  end

  def process
    set_input_from_file
    input.lines.each do |line|
      process_line(line)
    end
  end

  def process_line(line)
    line = line.strip
    validate_line(line)

    action, *items = line.split(/\s+/)
    validate(action, items)

    take_action(action, items)
  end

  def take_action(action, items)
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
      finish
    else
      raise InvalidAction
    end
  end

  def add_to_output(message, with_new_line: true)
    output_text = message
    output_text += "\n" if with_new_line
    @output << output_text
  end

  def add_dependency(items)
    depends_on = items.slice(1, items.length)
    @dependencies.add(items.first, depends_on)
    add_to_output('DEPEND ' + items.join(' '))
  end

  def install(item)
    output_text = "INSTALL #{item}\n"
    if already_installed?(item)
      output_text += "  #{item} is already installed"
      add_to_output(output_text)
      return
    end

    install_dependencies(item, output_text)

    mark_as_installed(item)
  end

  def install_dependencies(item, output_text)
    @dependencies.get_deps_for_item(item).each do |it|
      output_text += "  Installing #{it}\n" unless already_installed?(it)
      mark_as_installed(it)
    end
    output_text += "  Installing #{item}"
    add_to_output(output_text)
  end

  def remove(item)
    output_text = "REMOVE #{item}\n"

    unless @installed_items.item_exists?(item)
      output_text += "  #{item} is not installed"
      add_to_output(output_text)
      return
    end

    unless okay_to_remove?(item)
      output_text += "  #{item} is still needed"
      add_to_output(output_text)
    else
      remove_dependencies(item, output_text)
    end
  end

  def remove_dependencies(item, output_text)
    output_text += "  Removing #{item}\n"
    @dependencies.get_deps_for_item(item).each do |it|
      if @installed_items[it] == 1
        output_text += "  Removing #{it}\n"
      end

      mark_as_uninstalled(it)

      @dependencies.delete(item)
      mark_as_uninstalled(item)
    end

    add_to_output(output_text, with_new_line:false)
  end

  def list
    output_text = "LIST\n  "
    output_text += @installed_items.keys.join("\n  ")
    add_to_output(output_text)
  end

  def finish
    add_to_output('END')
  end

  def print_output
    puts output.join('')
  end

  private

  def validate_line(line)
    raise LineTooLong if line.size > 80
  end

  def validate(action, items)
    items.each do |item|
      raise InvalidItem if item.size > 10
    end
  end

  def okay_to_remove?(item)
    @dependencies.does_another_item_depend_on?(item)
  end

  def already_installed?(item)
    @installed_items.item_exists?(item)
  end

  def mark_as_installed(item)
    @installed_items.mark_as_installed(item)
  end

  def mark_as_uninstalled(item)
    @installed_items.mark_as_uninstalled(item)
  end

  def set_input_from_file
    @input = read_file
  end
end
