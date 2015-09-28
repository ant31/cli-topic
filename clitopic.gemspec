require 'rake'
require 'date'
require File.join(File.dirname(__FILE__), 'lib/clitopic/version')

Gem::Specification.new do |s|
  s.name = 'cli-topic'
  s.version = ::Clitopic::VERSION
  s.licenses = ['MIT']
  s.date = Date.today.to_s
  s.summary = 'Small framework to build CLI.',
  s.description = 'Small framework to build CLI organised in topics/subcommands.',
  s.homepage = 'https://gitlab.com/ant31/cli-topics',
  s.authors = ['Antoine Legrand'],
  s.email = ['ant.legrand@gmail.com'],
  s.files = FileList['README.md', 'License', 'Changelog', 'lib/**/*.rb', 'lib/vendor/**/*.rb'].to_a
  s.test_files = FileList['spec/**/*.rb', 'spec/*.rb'].to_a
   # s.executables << 'clito'
  s.add_development_dependency "rspec",

  s.required_ruby_version = '>= 2.0.0'
end
