require_relative './associatable'
require_relative './db_connection' # use DBConnection.execute freely here.
require_relative './mass_object'
require_relative './searchable'

class SQLObject < MassObject
  extend Searchable
  extend Associatable

  def self.set_table_name(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name
  end

  def self.all
    search = DBConnection.execute(<<-SQL,
    SELECT
      *
    FROM
      "#{@table_name}"
    SQL
    )

    self.parse_all(search)

  end

  def self.find(id)
    search = DBConnection.execute(<<-SQL,
    SELECT
      *
    FROM
      "#{@table_name}"
    WHERE
      "#{@table_name}".id = "#{id}"
    SQL
    )

    result = self.parse_all(search)[0]

  end


  def create
    columns = self.class.attributes.join(", ")
    columns_count = self.class.attributes.count
    question_marks = (columns_count * ['?']).join(", ")
    values = self.attribute_values

    DBConnection.execute(<<-SQL, *values
        INSERT INTO #{@table_name} (#{columns})
        VALUES (#{question_marks})
        SQL
        )

    self.id = DBConnection.last_insert_row_id
  end

  def update
    attr_set = self.class.attributes.map do |attribute|
      "#{attribute} = ?"
    end.join(", ")

    values = self.attribute_values
    DBConnection.execute(<<-SQL, *values
        UPDATE #{self.class.table_name}
        SET #{attr_set}
        WHERE #{self.class.table_name}.id = #{self.id}
        SQL
        )
  end

  def save
    unless self.id.nil?
      self.update
    else
      self.create
    end
  end

  def attribute_values
    self.class.attributes.map {|attribute| self.send(attribute)}
  end
end
