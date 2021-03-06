class CheckoutTest < MiniTest::Test
  def setup
    (1..3).map do |item|
      var_name    = "@prod_#{item.to_s}"
      item_code   = "COD#{item.to_s}"
      item_name   = "Name of item ##{item.to_s}"
      item_price  = rand(0.01..1000.00)
      item_object = Product.new(item_code, item_name, item_price)
      
      self.instance_variable_set(var_name, item_object)
    end
    
    @basket      = Basket.new(@prod_1, @prod_2, @prod_3)
    @checkout    = Checkout.new(@basket)
    @accept_msg  = "Ready to scan..."
    @reject_msg  = "Cannot scan, no products present."
    @bogo_prod_1 = Discount.new("BOGO",
                                "Buy one #{@prod_1.name}, get one free #{@prod_1.name}",
                                @prod_1.price)
    
    @bogo_prod_2 = Discount.new("BOGO",
                                "Buy one #{@prod_1.name}, get one free #{@prod_2.name}",
                                @prod_2.price)
    
    @rduc_prod_1 = Discount.new("RDUC",
                                "Price drop after purchase of 3 or more",
                                2.5)
  end
  
  def test_accepts_products
    co = Checkout.new(@prod_1)
    assert_equal @accept_msg, co.message
    assert_equal [@prod_1.hashed], co.items_to_scan
  end
  
  def test_accepts_baskets
    assert_equal @accept_msg, @checkout.message
    assert_equal @basket.items, @checkout.items_to_scan
  end
  
  def test_rejects_non_products_and_non_baskets
    input_tests = [ Checkout.new,
                    Checkout.new("string"),
                    Checkout.new(['array','of','strings']),
                    Checkout.new({ code: 'hash', name: 'like a product', price: 0 }),
                    Checkout.new([{ code: 'array', name: 'of hashes', price: 0 }])]
    
    input_tests.map {|i| i.message }.each do |c|
      assert_equal @reject_msg, c
    end
    
    input_tests.each do |i|
      assert_nil i.items_to_scan
    end
  end
  
  def test_scanned_items_defaults_to_empty_array
    assert_equal [], @checkout.scanned_items
  end
  
  def test_scan_allows_input_to_scan_all
    all_items = @checkout.items_to_scan
    @checkout.scan('all')
    assert_equal all_items, @checkout.scanned_items
    assert_equal [], @checkout.items_to_scan
  end
  
  def test_clear_scanned_removes_all_items_from_scanned_items
    @checkout.scan('all')
    @checkout.clear_scanned
    assert_equal [], @checkout.scanned_items
  end
  
  def test_clear_scanned_adds_items_from_scanned_items_back_to_items_to_scan
    expected = [@prod_1, @prod_2, @prod_3].map {|p| p.hashed }
    
    @checkout.scan('all')
    @checkout.clear_scanned
    assert_equal expected, @checkout.items_to_scan
    
    @checkout.scan(1)
    @checkout.clear_scanned
    assert_equal expected, @checkout.items_to_scan
  end
  
  def test_clear_scanned_does_not_put_discount_items_back_into_items_to_scan
    bskt = Basket.new(@prod_1, @bogo_prod_1, @prod_2)
    co   = Checkout.new(bskt)
    
    co.scan('all')
    
    assert_equal [@prod_1.hashed, @bogo_prod_1.hashed, @prod_2.hashed], co.scanned_items
    co.clear_scanned
    
    assert_equal [@prod_1.hashed, @prod_2.hashed], co.items_to_scan
  end
    
  def test_scan_allows_input_of_last_index_to_scan_up_to
    @checkout.scan(0)
    assert_equal [@prod_1.hashed], @checkout.scanned_items
    assert_equal [@prod_2.hashed, @prod_3.hashed], @checkout.items_to_scan
    
    @checkout.scan(1)
    assert_equal [@prod_1.hashed, @prod_2.hashed], @checkout.scanned_items
    assert_equal [@prod_3.hashed], @checkout.items_to_scan
  end
  
  def test_scan_does_not_do_anything_with_incorrect_parameters
    [ "some other string",
      0.2345,
      { code: 'a', name: 'hash' },
      ['an', 'array','of','strings']
    ].each do |input_example|
        assert_equal "Unrecognized input.", @checkout.scan(input_example)
        assert_equal [], @checkout.scanned_items
        assert_equal @basket.items, @checkout.items_to_scan
      end
  end
  
  def test_total_returns_total_price_of_scanned_items
    @checkout.scan('all')
    assert_equal @basket.items.map {|i| i[:price] }.inject(:+), @checkout.total
  end
  
  def setup_discounts
    bskt = Basket.new
    3.times do
      bskt.add(@prod_1)
      bskt.add(@prod_2)
    end
    
    @co   = Checkout.new(bskt)
    @ph_1 = @prod_1.hashed
    @ph_2 = @prod_2.hashed
    @bh_1 = @bogo_prod_1.hashed
    @bh_2 = @bogo_prod_2.hashed
  end
  
  def test_apply_bogo_subtracts_as_expected_for_same_item
    setup_discounts
    
    @co.scan(0)
    @co.apply_bogo(@prod_1)
    assert_equal [@ph_1], @co.scanned_items
    
    @co.scan(2)
    @co.apply_bogo(@prod_1)
    assert_equal [@ph_1, @ph_2, @ph_1, @bh_1], @co.scanned_items

    @co.scan('all')
    @co.apply_bogo(@prod_1)
    assert_equal [@ph_1, @ph_2, @ph_1, @bh_1, @ph_2, @ph_1, @ph_2], @co.scanned_items
  end
  
  def test_apply_bogo_subtracts_as_expected_for_different_item
    setup_discounts
    
    @co.scan(1)
    @co.apply_bogo(@prod_1, @prod_2)
    assert_equal [@ph_1, @ph_2, @bh_2], @co.scanned_items
    
    @co.scan(3)
    @co.apply_bogo(@prod_1, @prod_2)
    assert_equal [@ph_1, @ph_2, @bh_2, @ph_1, @ph_2, @bh_2], @co.scanned_items

    @co.scan('all')
    @co.apply_bogo(@prod_1, @prod_2)
    assert_equal [@ph_1, @ph_2, @bh_2, @ph_1, @ph_2, @bh_2, @ph_1, @ph_2, @bh_2],
                 @co.scanned_items
  end
  
  def test_apply_bogo_allows_for_a_limit_to_the_discount
    bskt = Basket.new
    
    7.times do
      bskt.add(@prod_1)
    end
    
    ph_1 = @prod_1.hashed
    bh_1 = @bogo_prod_1.hashed
    
    co   = Checkout.new(bskt)
    
    co.scan('all')
    co.apply_bogo(@prod_1, @prod_1, 2)
    assert_equal [ph_1, ph_1, bh_1, ph_1, ph_1, bh_1, ph_1, ph_1, ph_1],
                 co.scanned_items
  end
  
  def test_reduce_price_reduces_price_after_threshhold_reached
    bskt = Basket.new
  
    5.times do
      bskt.add(@prod_1)
    end
    
    ph_1 = @prod_1.hashed
    rh_1 = @rduc_prod_1.hashed
    co   = Checkout.new(bskt)
    
    co.scan('all')
    co.reduce_price(@prod_1, 2.5, 3)
    
    assert_equal [ph_1, rh_1, ph_1, rh_1, ph_1, rh_1, ph_1, rh_1, ph_1, rh_1],
                 co.scanned_items
  end
end
