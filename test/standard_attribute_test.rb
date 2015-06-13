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

    def valid_form
      @valid_form ||= klass.new :item => 'valid'
    end

    def invalid_form
      @invalid_form ||= klass.new :item => 'invalid'
    end

    def teardown
      @klass = nil
      @valid_form = nil
      @invalid_form = nil
    end

    def test_attribute_returns_coerced_item_for_valid_input
      assert_equal Type, valid_form.item.class
    end

    def test_form_is_valid_with_valid_input
      assert_equal true, valid_form.valid?
    end

    def test_passes_attribute_name_and_attribute_value_to_each_block
      array = []
      valid_form.each { |name, value| array << name << value.class }
      assert_equal [:item, Type], array
    end

    def test_returns_an_enumerable_for_each_value
      enumerator = valid_form.each
      attribute_name, attribute_value = enumerator.next
      assert_equal :item, attribute_name
      assert_equal Type, attribute_value.class
    end

    def test_attribute_raises_error_if_input_was_invalid
      assert_raises ArgumentError do
        invalid_form.item
      end
    end

    def test_attribute_with_invalid_input_passes_error_to_block
      raw, error = invalid_form.item { |r, e| return r, e }
      assert_equal ArgumentError.new, error
    end

    def test_attribute_with_invalid_input_passes_raw_value_to_block
      raw, error = invalid_form.item { |r, e| return r, e }
      assert_equal 'invalid', raw
    end

    def test_form_is_invalid_with_invalid_input
      assert_equal false, invalid_form.valid?
    end

    def test_attribute_returns_nil_for_missing_input
      form = klass.new
      assert_equal nil, form.item
    end

    def test_attribute_returns_nil_for_nil_input
      form = klass.new :item => nil
      assert_equal nil, form.item
    end

    def test_attribute_returns_nil_for_blank_input
      form = klass.new :item => ''
      assert_equal nil, form.item
    end

  end
end
