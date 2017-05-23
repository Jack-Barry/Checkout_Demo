Dir[File.dirname(__FILE__) + '/models/*.rb'].each {|file| require file }

chai 	 = Product.new('CH1', 'Chai', 3.11)
apples = Product.new('AP1', 'Apples', 6)
coffee = Product.new('CF1', 'Coffee', 11.23)
milk   = Product.new('MK1', 'Milk', 4.75)

@basket 		= Basket.new(chai, apples, coffee, milk)
@checkout   = Checkout.new(@basket)

@checkout.scan(1)

@checkout.print_receipt