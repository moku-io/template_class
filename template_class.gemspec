# frozen_string_literal: true

require_relative 'lib/template_class/version'

Gem::Specification.new do |spec|
  spec.name = 'template_class'
  spec.version = TemplateClass::VERSION
  spec.authors = ['Moku S.r.l.', 'Riccardo Agatea']
  spec.email = ['info@moku.io']
  spec.license = 'MIT'

  spec.summary = 'A way to define templated classes, in a similar fashion to C++ templates.'
  spec.description = 'In most cases Ruby doesn\'t need templated classes, nor any other system of generics, because it isn\'t statically type checked. However, sometimes we need to automatically generate multiple similar classes, either because of poor design or because of external necessities. For example, to define a GraphQL schema with GraphQL Ruby (https://graphql-ruby.org/) we need to define a distinct class for each type. Since GraphQL is statically type checked but doesn\'t provide generics, if we need a set of similar but distinct types we\'re left to define them one by one.'
  spec.homepage = 'https://github.com/moku-io/template_class'
  spec.required_ruby_version = '>= 3.0.0' # Maybe we should check (?)

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/moku-io/template_class'
  spec.metadata['changelog_uri'] = 'https://github.com/moku-io/template_class'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir __dir__ do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|circleci)|appveyor)})
    end
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'activesupport'
end
