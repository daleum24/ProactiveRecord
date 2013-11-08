require 'active_support/core_ext/object/try'
require 'active_support/inflector'
require_relative './db_connection.rb'

class AssocParams
  def other_class
    @name.constantize
  end

  def other_table
    @name.constantize.table_name
  end
end

class BelongsToAssocParams < AssocParams
  def initialize(name, params)
    @name             = name
    @other_class_name = params[:class_name]  || name.camelize
    @primary_key      = params[:primary_key] || "id"
    @foreign_key      = params[:foreign_key] || (name.camelize + '_id')
  end

  def type
  end
end

class HasManyAssocParams < AssocParams
  def initialize(name, params, self_class)
  end

  def type
  end
end

module Associatable
  def assoc_params
  end

  def belongs_to(name, params = {})
    self.send(:define_method, name.to_sym) do

      search = DBConnection.execute(<<-SQL,
      SELECT
        *
      FROM
        "#{@table_name}"
      SQL
      )

      self.parse_all(search)

    end
  end

  def has_many(name, params = {})
  end

  def has_one_through(name, assoc1, assoc2)
  end
end
