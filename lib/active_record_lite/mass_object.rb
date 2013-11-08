class MassObject

  # takes a list of attributes.
  # creates getters and setters.
  # adds attributes to whitelist.
  def self.my_attr_accessible(*attributes)
    @attributes = []
    attr_arr = attributes.map { |attribute| attribute }

    attr_arr.each do |arg|

      define_method("#{arg}") { self.instance_variable_get("@#{arg}".to_s) }
      define_method("#{arg}=") { |val| self.instance_variable_set("@#{arg}".to_s, val) }
      @attributes << arg.to_sym

    end

  end

  # returns list of attributes that have been whitelisted.
  def self.attributes
    @attributes
  end

  def get(atr)
    instance_variable_get("@#{atr}")
  end

  # takes an array of hashes.
  # returns array of objects.
  def self.parse_all(results)
    results.map { |result| self.new(result) }
  end

  # takes a hash of { attr_name => attr_val }.
  # checks the whitelist.
  # if the key (attr_name) is in the whitelist, the value (attr_val)
  # is assigned to the instance variable.
  def initialize(params = {})
    attribute_arr = []

    params.each do |key, value|

      key.is_a?(String) ? key_sym = key.to_sym : key_sym = key

      if self.class.attributes.include?(key_sym)
        attribute_arr << key_sym
      else
        raise Exception.new
      end
    end

    self.class.my_attr_accessible(*attribute_arr)

    params.each do |key, value|
      self.send("#{key}=" ,value)
    end

  end
end