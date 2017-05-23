class BasketTest < MiniTest::Test
  def setup
    @prod_1 = Product.new("COD1", "Name of Product 1", 10)
    @prod_2 = Product.new("COD2", "Name of Product 2", 5.5)
    @empty  = { code: "EMPT", name: "Nothing in basket", price: 0 }
    @reject = { code: "RJCT", name: "Rejected - Not a product", price: 0 }
    @basket = Basket.new(@prod_1, @prod_2)
  end
  
  def test_empty_code_returns_proper_hash
    assert_equal @empty, @basket.empty_code
  end
  
  def test_reject_code_returns_proper_hash
    assert_equal @reject, @basket.reject_code
  end
  
  def test_converts_empty_attributes
    empty = Basket.new
    assert_equal [@empty], empty.items
  end
  
  def test_add_puts_item_into_basket
    @basket.add(@prod_1)
    
    assert_equal @basket.items, [ @prod_1.hashed,
                                  @prod_2.hashed,
                                  @prod_1.hashed ]
  end
  
  def test_add_rejects_item_if_not_product
    @basket.add("something")
    
    assert_equal @basket.items, [ @prod_1.hashed,
                                  @prod_2.hashed,
                                  @reject ]
  end
  
  def test_add_to_empty_basket_removes_empty_code
    empty = Basket.new
    empty.add(@prod_1)
    
    assert_equal [ @prod_1.hashed ], empty.items
  end
  
  def test_remove_takes_item_out_of_basket
    @basket.remove(@prod_1)
    
    assert_equal [ @prod_2.hashed ], @basket.items
  end
  
  def test_remove_returns_proper_alert
    assert_equal "#{@prod_1.name} was removed from the basket.", @basket.remove(@prod_1)
  end
  
  def test_remove_takes_only_one_item_out_of_basket
    @basket.add(@prod_1)
    @basket.remove(@prod_1)
    
    assert_equal [ @prod_1.hashed, @prod_2.hashed], @basket.items
  end
  
  def test_remove_ignores_non_products
    @basket.remove("non item")
    
    assert_equal [ @prod_1.hashed, @prod_2.hashed ], @basket.items
    assert_equal "Cannot remove item, it is not a product.", @basket.remove("non item")
  end
  
  def test_remove_last_product_adds_empty_code
    @basket.remove(@prod_1)
    @basket.remove(@prod_2)
    
    assert_equal [ @empty ], @basket.items
  end
end