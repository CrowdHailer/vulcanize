require_relative './test_config'

module Vulcanize
  class FormTest < MiniTest::Test
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

    def test_obtains_item_when_valid
      form = klass.new :item => 'valid'
      assert_equal Type, form.item.class
    end

    def test_form_is_valid_with_input
      form = klass.new :item => 'valid'
      assert_equal true, form.valid?
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
