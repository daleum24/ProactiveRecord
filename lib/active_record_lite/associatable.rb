require 'active_support/core_ext/object/try'
require 'active_support/inflector'
require_relative './db_connection.rb'

class AssocParams
  attr_accessor :name, :other_class_name, :primary_key, :foreign_key

  def other_class
    @other_class_name.to_s.capitalize.constantize
  end

  def other_table
    other_class.table_name
  end
end

class BelongsToAssocParams < AssocParams

  def initialize(name, params = {})
    @name             = name
    @other_class_name = params[:class_name]  || name.to_s.camelize
    @primary_key      = params[:primary_key] || "id"
    @foreign_key      = params[:foreign_key] || (name.to_s.underscore + '_id')
  end

  def type
  end
end

class HasManyAssocParams < AssocParams
  def initialize(name, params, self_class)
    @name             = name
    @other_class_name = params[:class_name]  || name.to_s.singularize.camelize
    @primary_key      = params[:primary_key] || "id"
    @foreign_key      = params[:foreign_key] || (self_class.underscore + '_id')
  end

  def type
  end
end

module Associatable
  def assoc_params
  end

  def belongs_to(name, params = {})
    settings = BelongsToAssocParams.new(name, params)

    self.send(:define_method, name.to_sym) do

      search = DBConnection.execute(<<-SQL, self.get(settings.foreign_key)
      SELECT
        *
      FROM #{settings.other_table}
      WHERE #{settings.other_table}.#{settings.primary_key} = ?
      SQL
      )
      return nil if search.empty?

      settings.other_class.new(search.first)
    end
  end

  def has_many(name, params = {})
    settings = HasManyAssocParams.new(name, params, self)
    
    self.send(:define_method, name.to_sym) do
      
    search = DBConnection.execute(<<-SQL, self.get(settings.primary_key)
    SELECT
      *
    FROM #{settings.other_table}
    WHERE #{settings.other_table}.#{settings.foreign_key} = ?
    SQL
    )
    return nil if search.empty?
    
    output = []
    
    search.each do |el|
      output << settings.other_class.new(el)
    end
    
    output
    
    end
  end

  def has_one_through(name, assoc1, assoc2)
  end
  
  
end





