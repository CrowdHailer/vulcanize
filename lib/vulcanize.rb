require "vulcanize/version"

module Vulcanize
  class Form
    def self.attributes
      @attributes ||= {}
    end


    def self.attribute(attribute_name, type, required: false, default: nil, from: nil)
      attributes[attribute_name] = true
      # from = from || attribute_name
      define_method attribute_name do |&block|
        begin
          raw = input[attribute_name]
          # raw = self.input.fetch(from) { '' }
          # raise MissingAttribute if required && raw.empty?
          return type.new raw
        rescue ArgumentError => err
          return block.call raw, err if block
          raise
        end
      end
      tmp_attributes = attributes

      define_method :attributes do
        tmp_attributes
      end
    end
    include Enumerable
    # http://blog.arkency.com/2014/01/ruby-to-enum-for-enumerator/
    def each
      attributes.each do |attribute, value|
        yield attribute, value
      end
    end

    def initialize(input={})
      @input = input
    end

    def valid?
      attributes.keys.each(&method(:send))
      true
    rescue
      false
    end

    attr_reader :input

  end
end
