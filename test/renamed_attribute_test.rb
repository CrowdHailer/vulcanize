require_relative './test_config'

module Vulcanize
  class RenamedAttributeTest < MiniTest::Test

    def klass
      return @klass if @klass
      klass = Class.new Form
      klass.attribute :item, TestType, :from => :other
      @klass = klass
    end

    def teardown
      @klass = nil
    end

    def test_attribute_is_fetched_from_optional_from_parameter
      form = klass.new :other => 'valid'
      assert_equal TestType, form.item.class
    end
  end
end
