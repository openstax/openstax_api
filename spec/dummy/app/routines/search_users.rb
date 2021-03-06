# Dummy routine for testing the abstract search representer

class SearchUsers

  lev_routine

  uses_routine OSU::SearchAndOrganizeRelation,
               as: :search,
               translations: { outputs: { type: :verbatim } }

  SORTABLE_FIELDS = { 'name' => :name, 'created_at' => :created_at }

  protected

  def exec(params = {})
    uu = User.arel_table
    run(:search, relation: User.unscoped,
                 sortable_fields: SORTABLE_FIELDS,
                 params: params) do |with|
      with.keyword :username do |names|
        snames = to_string_array(names, append_wildcard: true)
        next @items = @items.none if snames.empty?

        @items = @items.where(uu[:username].matches_any(snames))
      end

      with.keyword :first_name do |names|
        snames = to_string_array(names, append_wildcard: true)
        next @items = @items.none if snames.empty?

        @items = @items.where(uu[:name].matches_any(snames))
      end

      with.keyword :last_name do |names|
        snames = to_string_array(names, append_wildcard: true).map { |name| "% #{name}" }
        next @items = @items.none if snames.empty?

        @items = @items.where(uu[:name].matches_any(snames))
      end
    end
  end
end
