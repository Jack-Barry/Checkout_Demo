class Checkout
	attr_accessor :items_to_scan, :message, :scanned_items
	
	def initialize(item = nil)
		@items_to_scan = 	if item.is_a? Product
												[item.hashed]
											elsif item.is_a? Basket
												item.items
											else
												nil
											end
		
		@message 			 =	(item.is_a? Product) || (item.is_a? Basket) ?
											"Ready to scan..." :
											"Cannot scan, no products present."
		
		clear_scanned
	end
	
	def clear_scanned
		@scanned_items ||= []
		
		@scanned_items.reverse.each do |i|
			@items_to_scan.unshift(i)
		end
		
		@scanned_items = []
	end
	
	def scan(up_to)
		if (up_to == 'all') || (up_to.is_a? Integer)
			clear_scanned
			num_items  = @items_to_scan.length - 1	
			last_index = (up_to == 'all' || up_to > num_items || up_to < 0) ? num_items : up_to
			
			@items_to_scan[0..last_index].each do |item|
				@scanned_items << item
			end
			
			@items_to_scan = @items_to_scan[last_index + 1..-1]
		else
			"Unrecognized input."
		end
	end
	
	def total
		@scanned_items.map {|i| i[:price]}.inject(:+)
	end
	
	def print_receipt
		width = 36
		printf "%-6s %-20s %s \n", 'Item', 'Name', 'Price'
		print ("-" * width) + "\n"
		
		@scanned_items.each do |item|
			printf "%-6s %-20s $%7.2f \n", item[:code], item[:name], item[:price]		
		end
		
		print ("-" * width) + "\n"
		printf (" " * (width - 8)) + "$%7.2f \n", self.total
	end
end