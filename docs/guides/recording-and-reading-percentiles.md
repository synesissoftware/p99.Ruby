# p99.Ruby - Recording and Reading Percentiles <!-- omit in toc -->

This guide shows how to record event durations with `P99::Histogram` and
interpret its percentile results.


## Table of Contents <!-- omit in toc -->

- [Create a histogram](#create-a-histogram)
- [Record event durations](#record-event-durations)
- [Choose a time unit](#choose-a-time-unit)
- [Read common percentiles](#read-common-percentiles)
- [Read custom percentiles](#read-custom-percentiles)
- [Interpret approximate values](#interpret-approximate-values)
- [Handle empty and overflowing histograms](#handle-empty-and-overflowing-histograms)


## Create a histogram

Require the library and create an empty histogram:

```Ruby
require 'p99'

histogram = P99::Histogram.new
```

The histogram has a fixed 64-bucket storage model, so its memory use does not
grow with the number of recorded events.


## Record event durations

Record each completed operation as an event. Select the method whose suffix
matches the unit of the duration:

```Ruby
histogram.push_event_time_ns(database_time_ns)
histogram.push_event_time_us(cache_time_us)
histogram.push_event_time_ms(request_time_ms)
histogram.push_event_time_s(batch_time_s)
```

Each method converts its argument to nanoseconds. A successful push returns
`true`; an invalid duration or a duration rejected after overflow returns
`false`.


## Choose a time unit

Use the unit that matches the value already produced by the measuring code:

* Use nanoseconds for APIs that already report high-resolution monotonic time;
* Use microseconds or milliseconds when those are the native measurement units;
* Use seconds for coarse-grained operations or externally supplied durations;

The stored and returned values are always nanoseconds, regardless of the input
method used.


## Read common percentiles

Read the percentile that matches the question being asked:

```Ruby
p50  = histogram.value_at_p50
p90  = histogram.value_at_p90
p99  = histogram.value_at_p99
p999 = histogram.value_at_p99_9
```

For example, p99 is useful when the slowest one percent of observations
matters. A percentile result is expressed in nanoseconds.

The fixed set can be read as a hash:

```Ruby
histogram.fixed_percentiles
# => { "p50" => ..., "p75" => ..., "p90" => ..., "p99" => ... }
```


## Read custom percentiles

Use `value_at_percentile` for one custom level:

```Ruby
histogram.value_at_percentile(99.5)
```

Use `values_at_percentiles` when several levels are needed:

```Ruby
histogram.values_at_percentiles([ 50.0, 90.0, 99.0, 99.9 ])
# => [ [50.0, ...], [90.0, ...], [99.0, ...], [99.9, ...] ]
```

Percentiles are expressed as values from 0.0 to 100.0. Values outside that
range are clamped to the nearest endpoint.


## Interpret approximate values

`P99::Histogram` uses 64 logarithmic power-of-two buckets and linearly
interpolates within the bucket containing the requested rank. Results are
therefore estimates, not exact values from a retained sample set.

Use the histogram for stable operational summaries and comparisons. If exact
sample retrieval or arbitrary quantile algorithms are required, use a data
structure designed to retain or sort the individual observations.


## Handle empty and overflowing histograms

Percentile and minimum/maximum queries return `nil` for an empty histogram:

```Ruby
histogram.value_at_p99       # => nil
histogram.min_event_time     # => nil
histogram.max_event_time     # => nil
```

`event_time_total` returns `nil` after the running total overflows. Use
`event_time_total_raw` to inspect the accumulated value and
`has_overflowed?` to check the overflow state. Rejected pushes return `false`.

Call `clear` to reset the histogram and begin a new measurement interval:

```Ruby
histogram.clear
```


<!-- ########################### end of file ########################### -->
