require_relative './db_connection'

module Searchable
  
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