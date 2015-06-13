require_relative './test_config'

module Vulcanize
  class DefaultAttributeTest < MiniTest::Test

    def klass
      return @klass if @klass
      klass = Class.new Form
      klass.attribute :item, TestType, :default => :default
      @klass = klass
    end

    def teardown
      @klass = nil
    end

    def test_attribute_returns_default_for_missing_input
      form = klass.new
      assert_equal :default, form.item
    end

    def test_attribute_returns_default_for_nil_input
      form = klass.new :item => nil
      assert_equal :default, form.item
    end

    def test_attribute_returns_default_for_blank_input
      form = klass.new :item => ''
      assert_equal :default, form.item
    end
  end
end
