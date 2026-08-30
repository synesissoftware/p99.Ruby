#! /usr/bin/env ruby
# ######################################################################## #
# File:     examples/measure_batch_latency.rb
#
# Purpose:  Example illustrating batch latency measurement
#
# Created:  30th August 2026
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
# EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, THE
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
# PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
# LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
# NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
# ######################################################################## #


$:.unshift File.join(File.dirname(__FILE__), '..', 'lib')

require 'p99'


tries = Integer(ENV.fetch('P99_TRIES', 20))
rng = Random.new(12_345)
histogram = P99::Histogram.new

puts "Measuring #{tries} batch operations..."

tries.times do |index|

  batch_size = rng.rand(1..4)
  start_ns = Process.clock_gettime(Process::CLOCK_MONOTONIC, :nanosecond)

  sleep(batch_size / 10_000.0)

  elapsed_ns = Process.clock_gettime(
    Process::CLOCK_MONOTONIC,
    :nanosecond,
  ) - start_ns
  histogram.push_event_time_ns(elapsed_ns)

  puts "  batch #{index + 1}: #{batch_size} items"
end

puts
puts "Batch count: #{histogram.event_count}"
puts "Backend: #{P99::IMPLEMENTATION}"
puts "Min latency: #{histogram.min_event_time} ns"
puts "Max latency: #{histogram.max_event_time} ns"
puts
puts 'Approximate percentiles:'
histogram.fixed_percentiles.each do |label, value|

  puts "  #{label}: #{value} ns"
end


# ############################## end of file ############################# #
