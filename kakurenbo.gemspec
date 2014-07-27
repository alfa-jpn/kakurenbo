# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'kakurenbo/version'

Gem::Specification.new do |spec|
  spec.name          = "kakurenbo"
  spec.version       = Kakurenbo::VERSION
  spec.authors       = ["alfa-jpn"]
  spec.email         = ["a.nkmr.ja@gmail.com"]

  spec.summary       = <<-EOF
    provides soft delete.
    Kakurenbo is a re-implementation of paranoia and acts_as_paranoid for Rails4.
    implemented a function that other gems are not enough.
  EOF

  spec.description   = <<-EOF
    provides soft delete.
    Kakurenbo is a re-implementation of paranoia and acts_as_paranoid for Rails4 and 3.
    implemented a function that other gems are not enough.

    The usage of the Kakurenbo is very very very simple. Only add `deleted_at`(datetime) to column.
    Of course you can use `acts_as_paranoid`.In addition, Kakurenbo has many advantageous.
  EOF

  spec.homepage      = "https://github.com/alfa-jpn/kakurenbo"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", ">= 3.0.0"
  spec.add_development_dependency "yard"
  spec.add_development_dependency "sqlite3"

  spec.add_dependency 'activerecord', '>= 4.0.2'
end
