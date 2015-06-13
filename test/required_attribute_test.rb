require_relative './test_config'

module Vulcanize
  class RequiredAttributeTest < MiniTest::Test

    def klass
      return @klass if @klass
      klass = Class.new Form
      klass.attribute :item, TestType, :required => true
      @klass = klass
    end

    def teardown
      @klass = nil
    end

    def test_attribute_raises_exception_for_missing_input
      form = klass.new
      assert_raises Vulcanize::AttributeRequired do
        form.item
      end
    end

    def test_form_is_invalid_for_missing_input
      form = klass.new
      assert_equal false, form.valid?
    end

    def test_attribute_raises_exception_for_nil_input
      form = klass.new :item => nil
      assert_raises Vulcanize::AttributeRequired do
        form.item
      end
    end

    def test_form_is_invalid_for_nil_input
      form = klass.new :item => nil
      assert_equal false, form.valid?
    end

    def test_attribute_raises_exception_for_blank_input
      form = klass.new :item => ''
      assert_raises Vulcanize::AttributeRequired do
        form.item
      end
    end

    def test_form_is_invalid_for_blank_input
      form = klass.new :item => ''
      assert_equal false, form.valid?
    end
  end
end
