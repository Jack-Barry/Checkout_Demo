require './models/product'

class Basket
	attr_accessor :items
	
	def initialize(*items)
		@items = items.nil? || items.flatten.empty? ?
						 [self.empty_code] : []
		
		items.flatten.each {|item| self.add(item) }
	end
	
	def empty_code
		{ code: "EMPT", name: "Nothing in basket", price: 0 }
	end
	
	def empty_product
		Product.new(*empty_code.values)
	end
	
	def reject_code
		{ code: "RJCT", name: "Rejected - Not a product", price: 0 }
	end
	
	def add(item)
		if item.is_a? Product
			@items << item.hashed
			empty_product = Product.new(*empty_code.values)
			self.remove(empty_product)
		else
			@items << reject_code
		end
	end
	
	def remove(item)
		if item.is_a? Product
			@items.reverse.each_with_index do |i, index|
				if i[:code] == item.code
					@items.delete_at (@items.length - 1 - index || @items.length)
					
					@items << empty_code if @items.empty?
					
					return "#{item.name} was removed from the basket."
				end
			end
		else
			"Cannot remove item, it is not a product."
		end
	end
end