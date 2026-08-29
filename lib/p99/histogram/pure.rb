
# ######################################################################## #
# File:     p99/histogram/pure.rb
#
# Purpose:  Pure-Ruby Histogram implementation for p99.Ruby
#
# Created:  4th August 2026
# Updated:  30th August 2026
#
# Home:     http://github.com/synesissoftware/p99.Ruby
#
# Author:   Matthew Wilson
#
# Copyright (c) 2026, Matthew Wilson and Synesis Information Systems
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are
# met:
#
# * Redistributions of source code must retain the above copyright
#   notice, this list of conditions and the following disclaimer.
#
# * Redistributions in binary form must reproduce the above copyright
#   notice, this list of conditions and the following disclaimer in the
#   documentation and/or other materials provided with the distribution.
#
# * Neither the names of the copyright holder nor the names of its
#   contributors may be used to endorse or promote products derived from
#   this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
# IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
# THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
# PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
# CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
# EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
# PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
# LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
# NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
# ######################################################################## #


=begin
=end

module P99

  # Number of logarithmic buckets in a {Histogram}.
  BUCKET_COUNT = 64

  # Maximum value representable as an unsigned 64-bit integer.
  UINT64_MAX = (1 << 64) - 1

  # Calculates the bucket index for a duration in nanoseconds.
  #
  # @param time_in_ns [Integer];
    #
  # @return [Integer]
  def self.bucket_index(time_in_ns)

    time_in_ns = Integer(time_in_ns)

    return 0 if time_in_ns <= 1

    floor_log2_u64_(time_in_ns)
  end

  # Attempts to obtain the inclusive nanosecond range for +index+.
  #
  # @param index [Integer];
  #
  # @return [Array(Integer, Integer), nil] +[lower, upper]+, or +nil+ if
  #   +index+ is out of range
  def self.bucket_range(index)

    index = Integer(index)

    return nil if index < 0 || index >= BUCKET_COUNT

    bucket_range_(index)
  end

  # Low-cost performance percentile histogram (pure-Ruby backend).
  #
  # Tracks event durations with nanosecond precision across 64 logarithmic
  # power-of-two buckets and approximates percentiles via linear
  # interpolation within buckets.
  class Histogram

    def initialize

      clear
    end

    # Resets the histogram to the equivalent of a newly constructed
    # instance.
    #
    # @return [Histogram] +self+
    def clear

      @has_overflowed   = false
      @event_count      = 0
      @event_time_total = 0
      @min_event_time   = 0
      @max_event_time   = 0
      @buckets          = Array.new(BUCKET_COUNT, 0)

      self
    end

    # Records an event duration in nanoseconds.
    #
    # @param time_in_ns [Integer];
    #
    # @return [Boolean] +true+ on success; +false+ if overflow has already
    #   occurred or the running total would overflow
    def push_event_time_ns(time_in_ns)

      time_in_ns = coerce_u64_(time_in_ns)
      return false if time_in_ns.nil?

      bucket_index = P99.bucket_index(time_in_ns)

      return false unless try_add_ns_to_total_and_update_minmax_(time_in_ns)

      @event_count += 1
      @buckets[bucket_index] += 1

      true
    end

    # Records an event duration in microseconds.
    #
    # @param time_in_us [Integer];
    #
    # @return [Boolean]
    def push_event_time_us(time_in_us)

      time_in_us = coerce_u64_(time_in_us)
      return false if time_in_us.nil?

      if time_in_us > UINT64_MAX / 1000

        @has_overflowed = true

        return false
      end

      push_event_time_ns(time_in_us * 1000)
    end

    # Records an event duration in milliseconds.
    #
    # @param time_in_ms [Integer]
    # @return [Boolean]
    def push_event_time_ms(time_in_ms)

      time_in_ms = coerce_u64_(time_in_ms)
      return false if time_in_ms.nil?

      if time_in_ms > UINT64_MAX / 1_000_000

        @has_overflowed = true

        return false
      end

      push_event_time_ns(time_in_ms * 1_000_000)
    end

    # Records an event duration in seconds.
    #
    # @param time_in_s [Integer];
    #
    # @return [Boolean]
    def push_event_time_s(time_in_s)

      time_in_s = coerce_u64_(time_in_s)
      return false if time_in_s.nil?

      if time_in_s > UINT64_MAX / 1_000_000_000

        @has_overflowed = true

        return false
      end

      push_event_time_ns(time_in_s * 1_000_000_000)
    end

    # Number of recorded events.
    #
    # @return [Integer]
    attr_reader :event_count

    # Whether an arithmetic overflow has occurred.
    #
    # @return [Boolean]
    def has_overflowed?

      @has_overflowed
    end

    # Total event time in nanoseconds, or +nil+ if overflow has occurred.
    #
    # @return [Integer, nil]
    def event_time_total

      return nil if @has_overflowed

      event_time_total_raw
    end

    # Total event time in nanoseconds regardless of overflow status.
    #
    # @return [Integer]
    def event_time_total_raw

      @event_time_total
    end

    # Minimum observed event time in nanoseconds, or +nil+ if empty.
    #
    # @return [Integer, nil]
    def min_event_time

      return nil if @event_count == 0

      @min_event_time
    end

    # Maximum observed event time in nanoseconds, or +nil+ if empty.
    #
    # @return [Integer, nil]
    def max_event_time

      return nil if @event_count == 0

      @max_event_time
    end

    # Count of events in bucket +index+, or +nil+ if out of range.
    #
    # @param index [Integer];
    #
    # @return [Integer, nil]
    def bucket_value(index)

      index = Integer(index)

      return nil if index < 0 || index >= BUCKET_COUNT

      @buckets[index]
    end

    # Copy of all bucket counts.
    #
    # @return [Array<Integer>]
    def buckets

      @buckets.dup
    end

    # Approximated duration in nanoseconds at +percentile+.
    #
    # +percentile+ is clamped to +[0.0, 100.0]+.
    #
    # @param percentile [Numeric];
    #
    # @return [Integer, nil] +nil+ if the histogram is empty
    def value_at_percentile(percentile)

      return nil if @event_count == 0

      p = clamp_percentile_(percentile)

      return min_event_time if p <= 0.0
      return max_event_time if p >= 100.0

      target_rank = @event_count.to_f * (p / 100.0)
      accumulated = 0

      BUCKET_COUNT.times do |i|

        count = @buckets[i]

        next if count == 0

        prev_accumulated = accumulated
        accumulated += count

        if accumulated.to_f >= target_rank

          return value_at_percentile_in_bucket_(
            i, count, prev_accumulated, target_rank
          )
        end
      end

      max_event_time
    end

    # Approximated duration at p50.
    #
    # @return [Integer, nil]
    def value_at_p50

      value_at_target_rank_(u64_mul_div_(@event_count, 1, 2))
    end

    # Approximated duration at p75.
    #
    # @return [Integer, nil]
    def value_at_p75

      value_at_target_rank_(u64_mul_div_(@event_count, 3, 4))
    end

    # Approximated duration at p90.
    #
    # @return [Integer, nil]
    def value_at_p90

      value_at_target_rank_(u64_mul_div_(@event_count, 90, 100))
    end

    # Approximated duration at p95.
    #
    # @return [Integer, nil]
    def value_at_p95

      value_at_target_rank_(u64_mul_div_(@event_count, 95, 100))
    end

    # Approximated duration at p99.
    #
    # @return [Integer, nil]
    def value_at_p99

      value_at_target_rank_(u64_mul_div_(@event_count, 99, 100))
    end

    # Approximated duration at p99.5.
    #
    # @return [Integer, nil]
    def value_at_p99_5

      value_at_target_rank_(u64_mul_div_(@event_count, 995, 1000))
    end

    # Approximated duration at p99.9.
    #
    # @return [Integer, nil]
    def value_at_p99_9

      value_at_target_rank_(u64_mul_div_(@event_count, 999, 1000))
    end

    # Approximated duration at p99.99.
    #
    # @return [Integer, nil]
    def value_at_p99_99

      value_at_target_rank_(u64_mul_div_(@event_count, 9999, 10000))
    end

    # Approximated duration at p99.999.
    #
    # @return [Integer, nil]
    def value_at_p99_999

      value_at_target_rank_(u64_mul_div_(@event_count, 99999, 100000))
    end

    # Approximated duration at p99.9999.
    #
    # @return [Integer, nil]
    def value_at_p99_999_9

      value_at_target_rank_(u64_mul_div_(@event_count, 999999, 1000000))
    end

    # Approximated durations at multiple floating-point percentiles.
    #
    # @param levels [Array<Numeric>];
    #
    # @return [Array<Array(Numeric, Integer)>, nil] +nil+ if empty; otherwise
    #   an array of +[level, value]+ pairs
    def values_at_percentiles(levels)

      return nil if @event_count == 0

      levels = Array(levels)

      return [] if levels.empty?

      results = []

      levels.each do |level|

        value = value_at_percentile(level)

        return nil if value.nil?

        results << [ level, value ]
      end

      results
    end

    # Approximated durations at the fixed percentile set.
    #
    # @return [Hash{String=>Integer}, nil] keys +"p50"+ … +"p99.9999"+, or
    #   +nil+ if empty
    def fixed_percentiles

      return nil if @event_count == 0

      getters = [
        [ 'p50',      :value_at_p50 ],
        [ 'p75',      :value_at_p75 ],
        [ 'p90',      :value_at_p90 ],
        [ 'p95',      :value_at_p95 ],
        [ 'p99',      :value_at_p99 ],
        [ 'p99.5',    :value_at_p99_5 ],
        [ 'p99.9',    :value_at_p99_9 ],
        [ 'p99.99',   :value_at_p99_99 ],
        [ 'p99.999',  :value_at_p99_999 ],
        [ 'p99.9999', :value_at_p99_999_9 ],
      ]

      results = {}

      getters.each do |key, method_name|

        value = send(method_name)

        return nil if value.nil?

        results[key] = value
      end

      results
    end

    private

    def coerce_u64_(value)

      value = Integer(value)

      if value < 0 || value > UINT64_MAX

        @has_overflowed = true

        return nil
      end

      value
    end

    def try_add_ns_to_total_and_update_minmax_(time_in_ns)

      return false if @has_overflowed

      if time_in_ns > UINT64_MAX - @event_time_total

        @has_overflowed = true

        return false
      end

      @event_time_total += time_in_ns

      if @event_count == 0

        @min_event_time = time_in_ns
        @max_event_time = time_in_ns
      else

        @min_event_time = time_in_ns if time_in_ns < @min_event_time
        @max_event_time = time_in_ns if time_in_ns > @max_event_time
      end

      true
    end

    def value_at_target_rank_(target_rank)

      return nil if @event_count == 0

      accumulated = 0

      BUCKET_COUNT.times do |i|

        count = @buckets[i]

        next if count == 0

        prev_accumulated = accumulated
        accumulated += count

        if accumulated >= target_rank

          return value_at_target_rank_in_bucket_(
            i, count, prev_accumulated, target_rank
          )
        end
      end

      @max_event_time
    end

    def value_at_target_rank_in_bucket_(
      bucket_index,
      count,
      prev_accumulated,
      target_rank
    )

      range = P99.bucket_range(bucket_index)

      if range.nil?

        lower = 0
        upper = UINT64_MAX
      else

        lower, upper = range
      end

      if target_rank <= prev_accumulated

        interpolated = lower
      else

        target_offset = target_rank - prev_accumulated

        if bucket_index == BUCKET_COUNT - 1

          range_width = UINT64_MAX - lower
        else

          range_width = upper - lower
        end

        interpolated = lower + u64_mul_div_(range_width, target_offset, count)
      end

      clamp_to_minmax_(interpolated)
    end

    def value_at_percentile_in_bucket_(
      bucket_index,
      count,
      prev_accumulated,
      target_rank
    )

      range = P99.bucket_range(bucket_index)

      if range.nil?

        lower = 0
        upper = UINT64_MAX
      else

        lower, upper = range
      end

      target_offset = target_rank - prev_accumulated.to_f

      if bucket_index == BUCKET_COUNT - 1

        range_width = (UINT64_MAX - lower).to_f
      else

        range_width = (upper - lower).to_f
      end

      fraction = target_offset / count.to_f
      interpolated = lower.to_f + (range_width * fraction)

      clamp_to_minmax_(llround_(interpolated))
    end

    def clamp_to_minmax_(value)

      value = @min_event_time if value < @min_event_time
      value = @max_event_time if value > @max_event_time

      value
    end

    def clamp_percentile_(percentile)

      percentile = Float(percentile)

      return 0.0 if percentile < 0.0
      return 100.0 if percentile > 100.0

      percentile
    end

    def u64_mul_div_(multiplicand, multiplier, divisor)

      (multiplicand * multiplier) / divisor
    end

    def llround_(value)

      if value >= 0.0

        (value + 0.5).floor
      else

        (value - 0.5).ceil
      end
    end
  end # class Histogram

  class << self

    private

    def floor_log2_u64_(value)

      return value.bit_length - 1 if value.respond_to?(:bit_length)

      result = -1

      while value > 0

        value >>= 1
        result += 1
      end

      result
    end

    def bucket_range_(index)

      return [ 0, 1 ] if index == 0

      lower = 1 << index

      if index == BUCKET_COUNT - 1

        [ lower, UINT64_MAX ]
      else

        [ lower, (1 << (index + 1)) - 1 ]
      end
    end
  end
end # module P99


# ############################## end of file ############################# #
