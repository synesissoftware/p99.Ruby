# ######################################################################### #
# File:     p99.gemspec
#
# Purpose:  Gemspec for p99.Ruby library
#
# Created:  4th August 2026
# Updated:  4th August 2026
#
# ######################################################################### #


$:.unshift File.join(File.dirname(__FILE__), 'lib')

require 'p99/version'

require 'date'

Gem::Specification.new do |spec|

  spec.name         = 'p99-ruby'
  spec.version      = P99::VERSION
  spec.date         = Date.today.to_s
  spec.summary      = 'p99.Ruby'
  spec.description  = <<END_DESC
Low-cost generation of performance percentiles (p50, p90, p99, p99.9, etc.), for Ruby.

p99.Ruby is the Ruby implementation of the p99 family of libraries.
END_DESC
  spec.authors      = [ 'Matt Wilson' ]
  spec.email        = 'matthew@synesis.com.au'
  spec.homepage     = 'http://github.com/synesissoftware/p99.Ruby'
  spec.license      = 'BSD-3-Clause'

  spec.required_ruby_version = [ '>= 2.0', '< 4' ]

  spec.files = Dir[ 'Rakefile', '{bin,examples,lib,man,spec,test}/**/*', 'README*', 'LICENSE*' ] & `git ls-files -z`.split("\0")

  spec.add_development_dependency 'xqsr3', [ '~> 0.39', '>= 0.39.4' ]
end


# ############################## end of file ############################# #
