#! /usr/bin/env ruby
# ######################################################################## #
# File:     examples/build_histogram.rb
#
# Purpose:  Example illustrating P99::Histogram usage
#
# Created:  4th August 2026
# Updated:  4th August 2026
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


$:.unshift File.join(File.dirname(__FILE__), '..', 'lib')

require 'p99'


# Deterministic LCG used by the sibling p99 language examples.
class SimpleRng

  def initialize(seed)

    @state = seed & P99::UINT64_MAX
  end

  def next

    @state = (@state * 6_364_136_223_846_793_005 + 1) & P99::UINT64_MAX
  end
end


def format_ns(value)

  value.nil? ? 'nil' : value.to_s
end

def print_percentile(label, value)

  printf("  %-18s %s ns\n", label, format_ns(value))
end

def print_histogram(histogram)

  occupied = []

  histogram.buckets.each_with_index do |count, index|

    next if count == 0

    occupied << "#{index}: #{count}"
  end

  puts "Histogram{"
  puts "  implementation:   #{P99::IMPLEMENTATION}"
  puts "  event_count:      #{histogram.event_count}"
  puts "  event_time_total: #{format_ns(histogram.event_time_total)}"
  puts "  has_overflowed:   #{histogram.has_overflowed?}"
  puts "  min_event_time:   #{format_ns(histogram.min_event_time)}"
  puts "  max_event_time:   #{format_ns(histogram.max_event_time)}"
  puts "  buckets:          {#{occupied.join(', ')}}"
  puts "}"
end


tries = 100

if ENV.key?('P99_TRIES')

  begin

    tries = Integer(ENV['P99_TRIES'])
  rescue ArgumentError

    warn "Warning: failed to parse P99_TRIES value #{ENV['P99_TRIES'].inspect}, defaulting to 100"
    tries = 100
  end
end

puts "Running Histogram example with #{tries} tries..."
puts "(backend: #{P99::IMPLEMENTATION})"

histogram = P99::Histogram.new
rng = SimpleRng.new(12_345)

tries.times do

  delay_us = (rng.next % 1_000) + 1
  start_ns = Process.clock_gettime(Process::CLOCK_MONOTONIC, :nanosecond)

  sleep(delay_us / 1_000_000.0)

  elapsed_ns = Process.clock_gettime(Process::CLOCK_MONOTONIC, :nanosecond) - start_ns

  histogram.push_event_time_ns(elapsed_ns)
end

puts
puts 'Histogram summary:'
print_histogram(histogram)

puts
puts 'Percentiles (approximated):'
print_percentile('p50 (f64):', histogram.value_at_percentile(50.0))
print_percentile('p50 (integer):', histogram.value_at_p50)
print_percentile('p75 (integer):', histogram.value_at_p75)
print_percentile('p90 (integer):', histogram.value_at_p90)
print_percentile('p95 (integer):', histogram.value_at_p95)
print_percentile('p99 (integer):', histogram.value_at_p99)
print_percentile('p99.5 (integer):', histogram.value_at_p99_5)
print_percentile('p99.9 (integer):', histogram.value_at_p99_9)
print_percentile('p99.99 (integer):', histogram.value_at_p99_99)


# ############################## end of file ############################# #
