require 'delegate'

class Dependency < SimpleDelegator
  def initialize
    super({})
  end

  def add(item, deps)
    self[item] = deps
  end

  def mark_as_installed(item)
    number_of_installs = ( item_exists?(item) ? self[item] + 1 : 1 )
    add(item, number_of_installs)
  end

  def mark_as_uninstalled(item)
    if item_exists?(item)
      number_of_installs = self[item]
      if number_of_installs > 1
        number_of_installs -= 1
        self[item] = number_of_installs
      elsif number_of_installs == 1
        self.delete(item)
      end
    end
  end

  def get_deps_for_item(item)
    if item_exists?(item)
      return self[item]
    else
      return []
    end
  end

  def item_exists?(item)
    self.has_key?(item)
  end

  def does_another_item_depend_on?(item)
    okay = true
    self.values.each do |dependency|
      if dependency.include?(item)
        okay = false
        break
      end
    end
    okay
  end
end

#dep = Dependency.new
#dep['key'] = [1, 2, 3]
#dep['key'] # => [1, 2, 3]

