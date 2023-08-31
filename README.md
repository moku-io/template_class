# Template Class

A way to define templated classes, in a similar fashion to C++ templates.

In most cases Ruby doesn't need templated classes, nor any other system of generics, because it isn't statically type checked. However, sometimes we need to automatically generate multiple similar classes, either because of poor design or because of external necessities. For example, to define a GraphQL schema with [GraphQL Ruby](https://graphql-ruby.org/) we need to define a distinct class for each type. Since GraphQL is statically type checked but doesn't provide generics, if we need a set of similar but distinct types we're left to define them one by one.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'template_class', '~> 1.0'
```

And then execute:

```bash
$ bundle
```

Or you can install the gem on its own:

```bash
gem install template_class
```

## Usage

Include `TemplateClass::Template` in the class or module you want to make into a template. You can't make instances of a template; instead, you need to *specialize* it to some parameter. By default, any new specialization is an empty class. To define how a specialization is defined from a parameter, call `resolve_template_specialization`. The block you pass will be yielded the parameter that's specializing the template and a class constructor that makes it possible to recursively use the new specialization.

```ruby
class List
  include TemplateClass::Template

  resolve_template_specialization do |item_type, klass|
    klass.new do
      define_method :initialize do |items|
        unless items.all? {|item| item.is_a? item_type}
          raise ArgumentError
        end
        
        @items = items
      end
      
      define_method :push do |item|
        raise ArgumentError unless item.is_a? item_type
        
        @items.push item
      end
      
      def pop
        @items.pop
      end
    end
  end
end
```

`klass.new` behaves like `Class.new`, with the key difference that it saves the new class in the internal cache *before* it executes the block in the class scope. If you use `Class.new` the specialization still works as expected, but the class is cached *after* the block is executed, so a loop will be created if the code inside the block references the same specialization it is defining.

A module analogue to `klass` is passed as third parameter to the block:

```ruby
resolve_template_specialization do |item_type, _, mod|
  mod.new do
    ...
  end
end
```

`klass.new` and `mod.new` also redefine `inspect` and `to_s` for the new class/module, so in strings it will appear with the usual C++ style:

```ruby
List[Integer].to_s # => List<Integer>
```

If a specific specialization needs to be defined separately, you can set it explicitly. This will behave like a C++ full specialization.

```ruby
List[:any] = Array
```

Notice that the parameter isn't constrained to classes: you can use any object.

## Plans for future development

- Multiple specialization parameters
- Partial specialization

## Version numbers

Template Class loosely follows [Semantic Versioning](https://semver.org/), with a hard guarantee that breaking changes to the public API will always coincide with an increase to the `MAJOR` number.

Version numbers are in three parts: `MAJOR.MINOR.PATCH`.

- Breaking changes to the public API increment the `MAJOR`. There may also be changes that would otherwise increase the `MINOR` or the `PATCH`.
- Additions, deprecations, and "big" non breaking changes to the public API increment the `MINOR`. There may also be changes that would otherwise increase the `PATCH`.
- Bug fixes and "small" non breaking changes to the public API increment the `PATCH`.

Notice that any feature deprecated by a minor release can be expected to be removed by the next major release.

## Changelog

Full list of changes in [CHANGELOG.md](CHANGELOG.md)

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/moku-io/template_class.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
