class MassObject

  def self.my_attr_accessible(*attributes)
    @attributes = []
    attr_arr = attributes.map { |attribute| attribute }

    attr_arr.each do |arg|
      define_method("#{arg}") { self.instance_variable_get("@#{arg}".to_s) }
      define_method("#{arg}=") { |val| self.instance_variable_set("@#{arg}".to_s, val) }
      @attributes << arg.to_sym
    end

  end

  def self.attributes
    @attributes
  end

  def get(atr)
    instance_variable_get("@#{atr}")
  end


  def self.parse_all(results)
    results.map { |result| self.new(result) }
  end

  def initialize(params = {})
    attribute_arr = []

    params.each do |key, value|
      key_sym = key.is_a?(String) ? key.to_sym : key

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