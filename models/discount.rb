require_relative 'product'

class Discount < Product
	def initialize(code, name, price)
		super(code, name, price)
		
		@price = -price
	end
end