# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{toast}
  s.version = "0.0.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.add_dependency('twitter', '>= 0.6.12')
  s.add_dependency('sqlite3-ruby', '>= 1.2.4')

  s.authors = "Lloyd Pick"
  s.date = %q{2009-07-12}
  s.description = %q{Toast is a Ruby library for doing pre-defined automated tasks}
  s.email = %q{lloydpick@gmail.com}
  s.files = [ "lib/toast.rb" ]
  s.has_rdoc = false
  s.homepage = %q{https://github.com/lloydpick/toast}
  s.rdoc_options = ["--inline-source", "--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.0}
  s.summary = %q{Toast is a Rubygem for doing pre-defined automated tasks}
end
