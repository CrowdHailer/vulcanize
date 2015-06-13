require "vulcanize/version"
require "vulcanize/check_box"

module Vulcanize
  class Form
    def self.attributes
      @attributes ||= {}
    end

    def self.attribute(attribute_name, type, required: false, default: nil, from: nil, private: false)
      # attribute_name = attribute_name.to_sym
      attributes[attribute_name] = true
      # from = from.to_sym || attribute_name
      define_method attribute_name do |&block|
        raw = input[attribute_name]

        return nil if raw.nil? or raw.empty?
        
        begin
          # raw = self.input.fetch(from) { '' }
          # raise MissingAttribute if required && raw.empty?
          # return default if raw.empty?
          return type.new raw
        rescue ArgumentError => err
          return block.call raw, err if block
          raise
        end
      end
      tmp_attributes = attributes
      # private attribute_name if private

      define_method :attributes do
        tmp_attributes
      end
    end

    def initialize(input={})
      # handle symbolize keys
      @input = input
    end

    def each
      return enum_for(:each) unless block_given?

      attributes.each do |attribute, value|
        yield attribute, public_send(attribute)
      end
    end

    def valid?
      attributes.keys.each(&method(:send))
      true
      # handle argument error an missing error.
    rescue
      false
    end

    attr_reader :input

  end
end
