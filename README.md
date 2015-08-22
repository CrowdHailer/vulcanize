# Vulcanize

Form objects to handle coercing user input. [Blog post explaining the logic behind form objects](http://insights.workshop14.io/2015/07/23/application-border-control-with-ruby-form-objects.html)

[![Gem Version](https://badge.fury.io/rb/vulcanize.svg?style=flat-square)](http://badge.fury.io/rb/vulcanize) [![GitHub issues](https://img.shields.io/github/issues/crowdhailer/vulcanize.svg)](https://github.com/CrowdHailer/vulcanize/issues)

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

Forms consist of one or more attributes that are defined with a name, type and optional named parameters. Types are used to coerce the raw input and should be responsible for deciding a given inputs validity. If we have a `Name` domain object we can use it in a vulcanize form as follows. *Notes below on creating domain object*

```rb
class Form < Vulcanize::Form
  attribute :name, Name
end
```

The default behavior of an attribute is to coerce the input when it is valid, return `nil` when there is no input and to raise an error for invalid input.

```rb
# Create a form with a valid name
form = Form.new :name => 'Peter'

form.valid?
# => true

form.email
# => #<Name:0x00000002a579e8 @value="Peter">
```

```rb
# Create a form with a null name
form = Form.new :name => nil

form.valid?
# => true

form.email
# => nil
```

```rb
# Create a form with an invalid name
form = Form.new :name => '<DANGER!!>'

form.valid?
# => false

form.email
# !! ArgumentError
```

### Error Handling

Forms are designed to offer flexible error handling while limiting the ways that invalid can pass through to the core program. Each attribute method raises an error if the coercion fails or if raw input is missing from an attribute that was required. If a block is passed to the method then instead of failing the block will be called with the raw value and the error that would have been raised. This allows several different ways to handle bad input.

Usecase 1: return raw input and error so the user can edit the raw value.

```rb
form = Form.new :name => '<DANGER!!>'

value = form.email { |raw, _| raw }
error = form.email { |_, error| error }
```

Usecase 2: return a default value and error which a user may use.

```rb
form = Form.new :start_date => 'bad input'

value = form.start_date { |raw, _| DateTime.now }
error = form.start_date { |_, error| error }
```
### Note

All Ruby methods can take a block, this allows you to use the form in place of a domain object.

```rb
user.email { |raw, error| #Never called, user email method does not use a block }
```

### Default attribute
Attributes may have a default value that will be returned instead of nil when the raw value is nil or empty.

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

form.name
# => #<NullName:0x00000002aafb98>
```

### Required attribute
Attributes can be specified as being required. When the raw value is nil or empty retrieving the attribute vale will raise an `AttributeRequired` error and the form will be invalid.

```rb
class RequiredForm < Vulcanize::Form
  attribute :name, Name, :required => true
end

form = RequiredForm.new :name => ''

form.valid?
# => false

form.name
# !! Vulcanize::AttributeRequired
```

### Private attribute
Sometimes input needs to be coerced or validated but should not be available outside the form. The classic example is password confirmation in a form.

```rb
class PasswordForm < Vulcanize::Form
  attribute :password, Password, :required => true
  attribute :password_confirmation, Password, :private => true

  def valid?
    unless password == password_confirmation
      return false
    end
    super
  end
end
```

### Renamed attribute
Vulcanize can also be used to handle any input that can be cast as a hash. JSON data for example. It may be that input fields need renaming. That can be done with the 'from' parameter.

```rb
class RenameForm < Vulcanize::Form
  attribute :name, Name, :from => 'display_name'
end

form = RenameForm.new 'display_name' => 'Peter'

form.valid?
# => true

form.values
# => {:name => #<Name:0x00000002a579e8 @value="Peter">}
```

> Possible extension symbol option. if set true recases to symbol. if not leaves as input. default true. from could as be called field.

### Domain objects

The first step is to create your domain object. It should throw an ArgumentError if initialized with invalid arguments.

As an example here is a very simple implementation of a name object which has these conditions.
- It will always be capitalized
- It must be between 2 and 20 characters

```rb
class Name
  def initialize(raw)
    section = raw[/^\w{2,20}$/]
    raise ArgumentError unless section
    @value = section.capitalize
  end

  attr_reader :value
end
```

This [post](http://insights.workshop14.io/2015/07/15/value-objects-in-ruby.html) explains the rational behind value object.

For an example [email value object](https://github.com/CrowdHailer/typetanic/blob/master/lib/typetanic/email.rb) check [typetanic](https://github.com/CrowdHailer/typetanic)

### Check boxes
A common requirement is handling check boxes in HTML forms. There are two distinct requirements when handling these inputs. They are the 'optional check box' and the 'agreement check box'. Vulcanize provides a `CheckBox` coercer to handle these inputs.

#### Optional check box
With this check box the user is indicating true when it is checked and false when it is left unchecked. This can be achieved sing the default option

```rb
class OptionForm < Vulcanize::Form
  attribute :recieve_mail, Vulcanize::Checkbox, :default => false
end

form = OptionForm.new

form.recieve_mail
# => false

form.valid?
# => true
```

#### Agreement checkbox
This check box a user must select to continue. The check box checked should return a value of true. The check box left unchecked should invalidate the form.

```rb
class AgreementForm < Vulcanize::Form
  attribute :agree_to_terms, Vulcanize::Checkbox, :required => true
end

form = AgreementForm.new

form.agree_to_terms?
# !! #<Vulcanize::AttributeRequired: is not present>

form.valid?
# => false
```

#### Note on Checkbox
*`Vulcanize::CheckBox` returns true for an input of `'on'`. For all other values it raises an `ArgumentError`. This is to help debug if fields are incorrectly named.*

## Standard types
Vulcanize encourages using custom domain objects over ruby primitives. it is often miss-guided to use the primitives. I.e. 12 June 2030 is not a valid D.O.B for your users and '<|X!#' is not valid article body. However sometimes it is appropriate or prudent to use the basic types and for that reason you can specify the following as types of attributes.

- String

##### Note on using standard types
Often a reason to use standard types is because domain limitations on an input have not yet been defined. Instead of staying with strings consider using this minimal implementation.

```rb
class ArticleBody < String
end
```
## TODO
- section on testing
- actual api docs, perhaps formatted as in [AllSystems](https://github.com/CrowdHailer/AllSystems#user-content-docs)
- Handling collections, not necessary if always using custom collections
- question mark methods
- Pretty printing
- equality
- docs
form.each { |attribute, value| puts "#{attribute}, #{value}" }
# => :name, #<Name:0x00000002a579e8 @value="Peter">
- symbolize input

## Questions
- Form object with required and default might make sense if default acts as null object?
- Form object should have overwritable conditions on empty
- Check out virtus Array and Hash they might need to be included in awesomeness
  - There is no need for and array or hash type if Always defining collections
  - general nesting structure checkout useuful music batch

## Change log

Developed using Documentation Driven Development.
Few notes on Documentation Driven Development.
- [one](http://tom.preston-werner.com/2010/08/23/readme-driven-development.html)
- [two](http://24ways.org/2010/documentation-driven-design-for-apis)

**[Pull request for block errors](https://github.com/CrowdHailer/vulcanize/pull/1)**

## Contributing
There is no code here yet. So at the moment feel free to contribute around discussing these docs. pull request with your suggestion sounds perfect.

1. Fork it ( https://github.com/[my-github-username]/vulcanize/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
