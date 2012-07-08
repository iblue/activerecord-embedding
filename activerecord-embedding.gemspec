# -*- encoding: utf-8 -*-
require File.expand_path("../lib/active_record/embedding/version", __FILE__)

Gem::Specification.new do |s|
  s.name        = "activerecord-embedding"
  s.version     = ActiveRecord::Embedding::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Markus Fenske"]
  s.email       = ["iblue@gmx.net"]
  s.homepage    = "TODO: Homepage"
  s.summary     = "Adds MongoMapper embeds_many style behavior to ActiveRecord"
  s.description = "Adds MongoMapper embeds_many style behavior to ActiveRecord"

  s.required_rubygems_version = ">= 1.3.6"

  s.add_development_dependency "bundler", ">= 1.0.0"
  s.add_development_dependency "debugger"
  s.add_development_dependency "sqlite3"

  s.add_dependency "activerecord", "~> 3.0"

  s.files        = `git ls-files`.split("\n")
  s.executables  = `git ls-files`.split("\n").map{|f| f =~ /^bin\/(.*)/ ? $1 : nil}.compact
  s.require_path = 'lib'
end

