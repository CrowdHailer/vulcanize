module Vulcanize
  AttributeRequired = Class.new ArgumentError
  
  class Form
    def self.attributes
      @attributes ||= {}
    end

    def self.attribute(attribute_name, type, required: false, default: nil, from: nil, private: false)
      attributes[attribute_name] = private

      from = from || attribute_name

      define_method attribute_name do |&block|
        raw = input[from]

        missing = raw.nil? || raw.empty?

        fail AttributeRequired if required and missing
        return default if missing

        begin
          return type.new raw
        rescue ArgumentError => err
          return block.call raw, err if block
          raise
        end
      end
      tmp_attributes = attributes
      private attribute_name if private

      define_method :attributes do
        tmp_attributes
      end
    end

    def initialize(input={})
      input.keys.each do |key|
        input[(key.to_sym rescue key) || key] = input.delete(key)
      end
      @input = input
    end

    def each
      return enum_for(:each) unless block_given?

      attributes.each do |attribute, private|
        unless private
          yield attribute, public_send(attribute)
        end
      end
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
