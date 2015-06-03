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

### Default attribute
When declaring attributes a default may be provided for when the input is nil or empty.

```rb
class NullName
  def value
    'No name'
  end
end

class DefaultForm < Vulcanize::Form
  attribute :name, Name, :default => NullName.new
end

form = DefaultForm.new :name => ''

form.valid?
# => true

form.errors
# => {:name => #<Vulcanize::AttributeMissing: is not present>}

form.values
# => {:name =>nil}
```

### Required attribute
Perhaps instead of handling missing values you want the form to be invalid when values are missing. This can be set using the required option.

```rb
class RequiredForm < Vulcanize::Form
  attribute :name, Name, :required => true
end

form = RequiredForm.new :name => ''

form.valid?
# => false

form.values
# => {:name => #<NullName:0x00000001f457f8>}

form.name.value
# => 'No name'
```

### Private attribute
Sometimes input needs to be coerced or validated but should not be available outside the form. The classic example is password confirmation in a form.

```rb
class PasswordForm < Vulcanize::Form
  attribute :password, Password, :required => true
  attribute :password_confirmation, Password, :private => true

  def valid?
    unless password == password_confirmation
      error = ArgumentError.new 'does not match'
      errors.add(password_confirmation, error)
    end
    super
  end
end
```

### Renamed attribute
Vulcanize can also be used to handle any input that can be cast as a hash. JSON data for example. It may be that input fields need renaming. That can be done with the from attribute

```rb
class RenameForm < Vulcanize::Form
  attribute :name, Name, :from => 'display_name'
end

form = RenameForm.new :display_name => 'Peter'

form.valid?
# => true

form.values
# => {:name => #<Name:0x00000002a579e8 @value="Peter">}
```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/vulcanize/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
