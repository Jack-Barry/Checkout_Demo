class Checkout
	attr_accessor :items_to_scan, :message, :scanned_items
	
	def initialize(item = nil, bogos = nil)
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
			@items_to_scan.unshift(i) unless i[:price] < 0
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
	
	def apply_bogo(purchase, get = purchase, limit = nil)
		item_purchased   = false
		discount_applied = false
		discount         = Discount.new("BOGO",
																	  "Buy one #{purchase.name}, get one free #{get.name}",
																	  get.price)
		
		num_applied = 0
		
		@scanned_items.each_with_index do |item, index|
			break if limit != nil && num_applied >= limit
			next if item[:code] == "BOGO"
			
			if item_purchased && item[:code] == get.code && !discount_applied
				@scanned_items.insert(index + 1, discount.hashed)
				
				discount_applied = true
				item_purchased   = false
				num_applied      += 1	unless limit.nil?
			elsif item[:code] == purchase.code
				item_purchased   = true
				discount_applied = false
			end
		end
	end
	
	def reduce_price(product, amount, threshhold = 0)
		purchased_count = 0
		
		@scanned_items.each {|i| purchased_count += 1 if i[:code] == product.code }
		
		if purchased_count >= threshhold
			discount = Discount.new("RDUC",
															"Price drop after purchase of #{threshhold} or more",
															amount)
			
			@scanned_items.each_with_index do |item, index|
				next if item[:code] == "RDUC"
				
				if item[:code] == product.code
					@scanned_items.insert(index + 1, discount.hashed)
				end
			end
		end
	end
	
	def total
		@scanned_items.map {|i| i[:price]}.inject(:+)
	end
	
	def print_receipt
		width = 56
		printf "%-6s %-40s %s \n", 'Item', 'Name', 'Price'
		print ("-" * width) + "\n"
		
		@scanned_items.each do |item|
			printf "%-6s %-40s $%7.2f \n", item[:code], item[:name], item[:price]		
		end
		
		print ("-" * width) + "\n"
		printf (" " * (width - 8)) + "$%7.2f \n", self.total
		print "\n"
	end
end