#! /usr/bin/env ruby

$:.unshift File.join(File.dirname(__FILE__), '../../lib')


require 'p99/version'

require 'test/unit'


class Test_version < Test::Unit::TestCase

  def test_has_VERSION

    assert defined? P99::VERSION
  end

  def test_has_VERSION_MAJOR

    assert defined? P99::VERSION_MAJOR
  end

  def test_has_VERSION_MINOR

    assert defined? P99::VERSION_MINOR
  end

  def test_has_VERSION_REVISION

    assert defined? P99::VERSION_REVISION
  end

  def test_VERSION_has_consistent_format

    assert_equal P99::VERSION.split('.')[0..2].join('.'), "#{P99::VERSION_MAJOR}.#{P99::VERSION_MINOR}.#{P99::VERSION_REVISION}"
  end
end
