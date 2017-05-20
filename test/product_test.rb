class ProductTest < Minitest::Test
  def setup
    @product = Product.new("CODE", "Product Name", 10)
  end
  
  def test_attributes_are_properly_set
    assert_equal "CODE",         @product.code
    assert_equal "Product Name", @product.name
    assert_equal 10,             @product.price
  end
  
  def test_hashed_returns_product_attributes_as_hash
    assert_equal @product.hashed, { code:  "CODE",
                                    name:  "Product Name",
                                    price: 10 }
  end
end