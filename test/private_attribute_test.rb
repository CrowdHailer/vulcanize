require_relative './test_config'

module Vulcanize
  class PrivateAttributeTest < MiniTest::Test

    def klass
      return @klass if @klass
      klass = Class.new Form
      klass.attribute :item, TestType, :private => true
      @klass = klass
    end

    def teardown
      @klass = nil
    end

    def test_attribute_method_is_private
      form = klass.new :item => 'valid'
      assert_raises NoMethodError do
        form.item
      end
    end

    def test_private_attributes_do_not_show_up_in_each
      form = klass.new :item => 'valid'
      enumerator = form.each
      assert_equal 0, enumerator.count
    end
  end
end
