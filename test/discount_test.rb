class DiscountTest < MiniTest::Test
  def setup
    @discount = Discount.new('BOGO', 'Buy one get one', 15)
  end
  
  def test_inherits_from_product
    assert_equal true, (@discount.is_a? Product)
  end
  
  def test_converts_positive_amount_to_negative
    assert_equal (-15), @discount.price
  end
end