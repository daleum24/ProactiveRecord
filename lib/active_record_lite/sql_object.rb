require_relative './associatable'
require_relative './db_connection' # use DBConnection.execute freely here.
require_relative './mass_object'
require_relative './searchable'

class SQLObject < MassObject
  # sets the table_name

  extend Searchable
  extend Associatable

  def self.set_table_name(table_name)
    @table_name = table_name
  end

  # gets the table_name
  def self.table_name
    @table_name
  end

  # querys database for all records for this type. (result is array of hashes)
  # converts resulting array of hashes to an array of objects by calling ::new
  # for each row in the result. (might want to call #to_sym on keys)
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

  # querys database for record of this type with id passed.
  # returns either a single object or nil.
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

  # executes query that creates record in db with objects attribute values.
  # use send and map to get instance values.
  # after, update the id attribute with the helper method from db_connection

    private

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

    # executes query that updates the row in the db corresponding to this instance
    # of the class. use "#{attr_name} = ?" and join with ', ' for set string.
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

  public

  # call either create or update depending if id is nil.
  def save
    unless self.id.nil?
      self.update
    else
      self.create
    end
  end

  # helper method to return values of the attributes.
  def attribute_values
    self.class.attributes.map {|attribute| self.send(attribute)}
  end
end
