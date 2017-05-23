Dir[File.dirname(__FILE__) + '/models/*.rb'].each {|file| require file }

@chai   = Product.new('CH1', 'Chai', 3.11)
@apples = Product.new('AP1', 'Apples', 6)
@coffee = Product.new('CF1', 'Coffee', 11.23)
@milk   = Product.new('MK1', 'Milk', 4.75)

@basket_1 = Basket.new(@chai, @apples, @coffee, @milk)
@basket_2 = Basket.new(@milk, @apples)
@basket_3 = Basket.new(@coffee, @coffee)
@basket_4 = Basket.new(@apples, @apples, @chai, @apples)

def apply_discounts(checkout)
  checkout.apply_bogo(@coffee)
  checkout.apply_bogo(@chai, @milk, 1)
  checkout.reduce_price(@apples, 1.5, 3)
end

def scan_and_print(basket, up_to = 'all')
  checkout = Checkout.new(basket)
  checkout.scan(up_to)
  apply_discounts(checkout)
  checkout.print_receipt
  print "\n\n\n"
end

scan_and_print(@basket_1)
scan_and_print(@basket_2)
scan_and_print(@basket_3)
scan_and_print(@basket_4)