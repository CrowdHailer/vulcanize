# Vulcanize

Build simple form objects for custom value objects objects.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'vulcanize'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install vulcanize

## Usage

The first step is to create your value object. Your domain specific value object should implement the `typetanic/forge` protocol. The forge method can take any number of arguments to create a new value. It should accept a block which is called with the error should creating the value object fail.
The forging of a value object should carry out all coercions and validations specific to that type. Vulcanize form objects only know is a value is invalid or missing, not how an object might be invalid

As an example here is a very simple implementation of a name object.
- It will always be capitalized
- It must be between 2 and 20 characters

```rb
class Name
  def initialize(raw)
    section = raw[/^\w{2,20}$/]
    raise ArgumentError, 'is not valid' unless section
    @value = section.capitalize
  end

  attr_reader :value

  def self.forge(raw)
    new raw
  rescue ArgumentError => err
    yield err
  end
end
```

To use this create the following form

```rb
class Form < Vulcanize::Form
  attribute :name, Name
end

# Create a form with a valid name
form = Form.new :name => 'Peter'

form.valid?
# => true

form.errors
# => {}

form.values
# => {:name => #<Name:0x00000002a579e8 @value="Peter">}

# Create a form with an invalid name
form = Form.new :name => '<DANGER!!>'

form.valid?
# => false

form.validate!
# !! Vulcanize::InvalidForm

form.errors
# => {:name => #<ArgumentError: is not valid>}

form.values
# => {:name => '<DANGER!!>'}
```

### Null input
A types forge method is not called by default if the input given is nil.
To work with HTML forms empty string input is also treaded as a nil input.

Using the same form as above
```rb
form = Form.new :name => ''

form.valid?
# => true

form.errors
# => {}

form.values
# => {:name => nil}
```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/vulcanize/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
