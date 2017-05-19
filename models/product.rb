class Product
  attr_accessor :code, :name, :price
  
  def initialize(code, name, price)
    @code  = code
    @name  = name
    @price = price
  end
  
  def hashed
    self.instance_variables.each_with_object({}) do |var, hash|
      hash[var[1..-1].to_sym] = self.instance_variable_get(var)
    end
  end
end