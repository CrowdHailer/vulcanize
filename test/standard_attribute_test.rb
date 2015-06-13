require_relative './test_config'

module Vulcanize
  class StandardAttributeTest < MiniTest::Test
    class Type
      def initialize(value)
        fail ArgumentError unless value == 'valid'
      end
    end

    def klass
      return @klass if @klass
      klass = Class.new Form
      klass.attribute :item, Type
      @klass = klass
    end

    def teardown
      @klass = nil
    end

    def test_attribute_returns_coerced_item_for_valid_input
      form = klass.new :item => 'valid'
      assert_equal Type, form.item.class
    end

    def test_form_is_valid_with_valid_input
      form = klass.new :item => 'valid'
      assert_equal true, form.valid?
    end

    def test_passes_attribute_name_and_attribute_value_to_each_block
      form = klass.new :item => 'valid'
      array = []
      form.each { |name, value| array << name << value.class }
      assert_equal [:item, Type], array
    end

    def test_returns_an_enumerable_for_each_value
      form = klass.new :item => 'valid'
      e = form.each
      attribute_name, attribute_value = e.next
      assert_equal :item, attribute_name
      assert_equal Type, attribute_value.class
    end

    def test_raises_error_if_invalid_input
      form = klass.new :item => 'invalid'
      assert_raises ArgumentError do
        form.item
      end
    end

    def test_passes_error_to_block
      form = klass.new :item => 'invalid'
      raw, error = form.item { |r, e| return r, e }
      assert_equal 'invalid', raw
      assert_equal ArgumentError.new, error
    end

    def test_no_valid_if_invalid_input
      form = klass.new :item => 'invalid'
      assert_equal false, form.valid?
    end

  end
end
