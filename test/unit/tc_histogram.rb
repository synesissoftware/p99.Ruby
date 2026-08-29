#! /usr/bin/env ruby

$:.unshift File.join(File.dirname(__FILE__), '../../lib')


require 'p99'

require 'test/unit'


class Test_histogram < Test::Unit::TestCase

  def setup

    @h = P99::Histogram.new
  end

  def test_implementation_is_ruby

    assert_equal 'ruby', P99::IMPLEMENTATION
  end

  def test_default_histogram

    assert_equal 0, @h.event_count
    assert_equal 0, @h.event_time_total
    assert_equal 0, @h.event_time_total_raw
    assert_equal false, @h.has_overflowed?
    assert_nil @h.min_event_time
    assert_nil @h.max_event_time

    buckets = @h.buckets

    assert_equal P99::BUCKET_COUNT, buckets.size

    P99::BUCKET_COUNT.times do |i|

      assert_equal 0, buckets[i]
      assert_equal 0, @h.bucket_value(i)
    end

    assert_nil @h.bucket_value(64)
    assert_nil @h.bucket_value(-1)
  end

  def test_bucket_index

    cases = [
      [ 0, 0 ],
      [ 1, 0 ],
      [ 2, 1 ],
      [ 3, 1 ],
      [ 4, 2 ],
      [ 7, 2 ],
      [ 8, 3 ],
      [ 15, 3 ],
      [ 1024, 10 ],
      [ 2047, 10 ],
      [ 1 << 63, 63 ],
      [ P99::UINT64_MAX, 63 ],
    ]

    cases.each do |value, bucket|

      assert_equal bucket, P99.bucket_index(value), "value=#{value}"
    end
  end

  def test_bucket_range

    cases = [
      [ 0, 0, 1 ],
      [ 1, 2, 3 ],
      [ 2, 4, 7 ],
      [ 3, 8, 15 ],
      [ 4, 16, 31 ],
      [ 10, 1024, 2047 ],
      [ 63, 1 << 63, P99::UINT64_MAX ],
    ]

    cases.each do |index, lower, upper|

      assert_equal [ lower, upper ], P99.bucket_range(index)
    end

    assert_nil P99.bucket_range(64)
    assert_nil P99.bucket_range(-1)
  end

  def test_bucket_placement

    cases = [
      [ 0, 0 ],
      [ 1, 0 ],
      [ 2, 1 ],
      [ 3, 1 ],
      [ 4, 2 ],
      [ 7, 2 ],
      [ 8, 3 ],
      [ 15, 3 ],
      [ 1024, 10 ],
      [ 2047, 10 ],
      [ 1 << 63, 63 ],
      [ P99::UINT64_MAX, 63 ],
    ]

    cases.each do |value, bucket|

      @h.clear

      assert @h.push_event_time_ns(value)
      assert_equal 1, @h.bucket_value(bucket), "value=#{value}"
    end
  end

  def test_push_events

    assert @h.push_event_time_ns(1)
    assert @h.push_event_time_ns(3)
    assert @h.push_event_time_us(10)
    assert @h.push_event_time_ms(5)
    assert @h.push_event_time_s(2)
    assert @h.push_event_time_ns(100)

    assert_equal 6, @h.event_count
    assert_equal false, @h.has_overflowed?
    assert_equal 1, @h.min_event_time
    assert_equal 2_000_000_000, @h.max_event_time
    assert_equal 2_005_010_104, @h.event_time_total

    buckets = @h.buckets

    assert_equal 1, buckets[0]
    assert_equal 1, buckets[1]
    assert_equal 1, buckets[6]
    assert_equal 1, buckets[13]
    assert_equal 1, buckets[22]
    assert_equal 1, buckets[30]

    @h.clear

    assert_equal 0, @h.event_count
    assert_equal 0, @h.event_time_total
  end

  def test_overflow

    assert @h.push_event_time_ns(P99::UINT64_MAX)
    assert_equal P99::UINT64_MAX, @h.event_time_total
    assert_equal false, @h.has_overflowed?

    assert_equal false, @h.push_event_time_ns(1)
    assert_equal true, @h.has_overflowed?
    assert_nil @h.event_time_total
    assert_equal P99::UINT64_MAX, @h.event_time_total_raw
  end

  def test_percentiles_empty

    assert_nil @h.value_at_percentile(50.0)
    assert_nil @h.value_at_p50
    assert_nil @h.value_at_p99
    assert_nil @h.fixed_percentiles
    assert_nil @h.values_at_percentiles([ 50.0 ])
  end

  def test_percentiles_single_event

    assert @h.push_event_time_ns(100)

    [ 0.0, 50.0, 99.0, 100.0 ].each do |percentile|

      assert_equal 100, @h.value_at_percentile(percentile)
    end

    assert_equal 100, @h.value_at_p50
    assert_equal 100, @h.value_at_p90
    assert_equal 100, @h.value_at_p99
    assert_equal 100, @h.value_at_p99_999_9
  end

  def test_percentiles_interpolation

    assert @h.push_event_time_ns(100)
    assert @h.push_event_time_ns(200)

    p50 = @h.value_at_p50
    p99 = @h.value_at_p99

    assert_operator p50, :>=, 100
    assert_operator p50, :<=, 200
    assert_operator p99, :>=, 100
    assert_operator p99, :<=, 200
    assert_equal 100, @h.value_at_percentile(0.0)
    assert_equal 200, @h.value_at_percentile(100.0)
  end

  def test_percentiles_wide_range

    values = [
      1,
      10,
      100,
      1_000,
      10_000,
      100_000,
      1_000_000,
      10_000_000,
      100_000_000,
      1_000_000_000,
      10_000_000_000,
    ]

    values.each do |value|

      assert @h.push_event_time_ns(value)
    end

    assert_equal values.size, @h.event_count
    assert_equal 1, @h.min_event_time
    assert_equal 10_000_000_000, @h.max_event_time

    fixed = @h.fixed_percentiles

    refute_nil fixed

    ordered = [
      fixed['p50'],
      fixed['p75'],
      fixed['p90'],
      fixed['p95'],
      fixed['p99'],
      fixed['p99.5'],
      fixed['p99.9'],
      fixed['p99.99'],
      fixed['p99.999'],
      fixed['p99.9999'],
    ]

    assert_equal ordered.sort, ordered
    assert_operator ordered.first, :>=, 1
    assert_operator ordered.last, :<=, 10_000_000_000
  end

  def test_percentiles_many_events

    count = 100_000

    (1..count).each do |i|

      assert @h.push_event_time_ns(i)
    end

    assert_equal count, @h.event_count
    assert_equal 1, @h.min_event_time
    assert_equal count, @h.max_event_time
    assert_equal 50_000, @h.value_at_p50
    assert_equal 100_000, @h.value_at_p90
    assert_equal 100_000, @h.value_at_p99
    assert_equal 100_000, @h.value_at_p99_9
  end

  def test_compare_float_and_int_percentiles

    (1..10_000).each do |i|

      assert @h.push_event_time_ns((i * i) % 1_000_000)
    end

    pairs = [
      [ 50.0, :value_at_p50 ],
      [ 75.0, :value_at_p75 ],
      [ 90.0, :value_at_p90 ],
      [ 95.0, :value_at_p95 ],
      [ 99.0, :value_at_p99 ],
      [ 99.5, :value_at_p99_5 ],
      [ 99.9, :value_at_p99_9 ],
      [ 99.99, :value_at_p99_99 ],
      [ 99.999, :value_at_p99_999 ],
      [ 99.9999, :value_at_p99_999_9 ],
    ]

    pairs.each do |level, method_name|

      float_value = @h.value_at_percentile(level)
      int_value = @h.send(method_name)

      refute_nil float_value
      refute_nil int_value

      tolerance = [ float_value.abs * 0.01, 1.0 ].max

      assert_operator (float_value - int_value).abs, :<=, tolerance
    end
  end

  def test_values_at_percentiles_empty_levels

    assert @h.push_event_time_ns(100)
    assert_equal [], @h.values_at_percentiles([])
  end

  def test_values_at_percentiles

    assert @h.push_event_time_ns(100)
    assert @h.push_event_time_ns(200)

    results = @h.values_at_percentiles([ 0.0, 100.0 ])

    assert_equal [ [ 0.0, 100 ], [ 100.0, 200 ] ], results
  end

  def test_clear_returns_self

    assert_same @h, @h.clear
  end
end
