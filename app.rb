Dir[File.dirname(__FILE__) + '/models/*.rb'].each {|file| require file }
 
(1..3).map do |item|
	var_name 		= "@prod_#{item.to_s}"
	item_code 	= "COD#{item.to_s}"
	item_name 	= "Name of item ##{item.to_s}"
	item_price 	= rand(0.01..1000.00)
	item_object = Product.new(item_code, item_name, item_price)
	
	self.instance_variable_set(var_name, item_object)
end
	
@basket 		= Basket.new(@prod_1, @prod_2, @prod_3)
@checkout   = Checkout.new(@basket)

@checkout.scan('all')

@checkout.print_receipt