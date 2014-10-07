# Dummy routine for testing the abstract search representer

class SearchUsers < OpenStax::Utilities::AbstractKeywordSearchRoutine
  self.initial_relation = User.unscoped
  self.search_proc = lambda { |with|
    with.keyword :username do |names|
      snames = to_string_array(names, append_wildcard: true)
      @items = @items.where{username.like_any snames}
    end

    with.keyword :first_name do |names|
      snames = to_string_array(names, append_wildcard: true)
      @items = @items.where{name.like_any snames}
    end

    with.keyword :last_name do |names|
      snames = to_string_array(names, append_wildcard: true).collect{|name| "% #{name}"}
      @items = @items.where{name.like_any snames}
    end
  }
  self.sortable_fields_map = {'name' => :name, 'created_at' => :created_at, 'id' => :id}
end
