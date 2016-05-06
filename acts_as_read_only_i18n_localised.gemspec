# encoding: utf-8

$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
require 'acts_as_read_only_i18n_localised/version'

Gem::Specification.new do |s|
  s.name          = 'acts_as_read_only_i18n_localised'
  s.version       = ActsAsReadOnlyI18nLocalised::VERSION
  s.authors       = ['Dave Sag']
  s.email         = ['davesag@gmail.com']
  s.homepage      = 'http://github.com/davesag/acts_as_read_only_i18n_localised'
  s.summary       = 'Simple mechanism to allow localised lookups of seed data.'
  s.description   = 'A way to read localised data in Active Record models'
  s.license       = 'MIT'

  s.files         = `git ls-files`.split("\n")
  s.platform      = Gem::Platform::RUBY
  s.require_paths = ['lib']

  s.required_ruby_version = '>= 2.0.0'

  s.add_dependency 'i18n'

  s.add_development_dependency 'rspec'
  s.add_development_dependency 'binding_of_caller'
  s.add_development_dependency 'pry'
  s.add_development_dependency 'pry-remote'
  s.add_development_dependency 'pry-byebug'
end
