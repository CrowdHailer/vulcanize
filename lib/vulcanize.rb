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
    end

    def initialize(input={})
      @input = input
    end

    def valid?
      self.class.attributes.keys.each(&method(:send))
      true
    rescue
      false
    end

    attr_reader :input

  end
end
