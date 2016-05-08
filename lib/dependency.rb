require 'delegate'

class Dependency < SimpleDelegator
  def initialize
    super({})
  end

  def add(item, deps)
    self[item] = deps
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
end

#dep = Dependency.new
#dep['key'] = [1, 2, 3]
#dep['key'] # => [1, 2, 3]

