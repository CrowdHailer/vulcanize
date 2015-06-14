require_relative './test_config'

module Vulcanize
  class CheckBoxTest < MiniTest::Test

    def test_returns_true_for_checked_input
      value = CheckBox.new 'on'
      assert_equal true, value
    end

    def test_raises_argument_error_for_invalid_input
      assert_raises ArgumentError do
        CheckBox.new 'bad'
      end
    end
  end
end
