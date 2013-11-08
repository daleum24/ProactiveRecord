require_relative './db_connection'

module Searchable
  # takes a hash like { :attr_name => :search_val1, :attr_name2 => :search_val2 }
  # map the keys of params to an array of  "#{key} = ?" to go in WHERE clause.
  # Hash#values will be helpful here.
  # returns an array of objects
  def where(params)
    where_clause = params.map do |key,value|
      "#{key} = ?"
    end.join(" AND ")

    values = params.map do |key,value|
      "#{value}"
    end

    search = DBConnection.execute(<<-SQL, *values
    SELECT
      *
    FROM
      #{self.table_name}
    WHERE
      #{where_clause}
    SQL
    )

    self.parse_all(search)


  end
end