# p99.Ruby Histogram <!-- omit in toc -->

`P99::Histogram` is a fixed-size histogram for recording event durations and
estimating high percentiles such as p50, p90, p99, and p99.9. The current
release uses a pure-Ruby backend and stores durations in nanoseconds.


## Table of Contents <!-- omit in toc -->

- [Loading](#loading)
- [Recording durations](#recording-durations)
- [Reading statistics](#reading-statistics)
- [Reading percentiles](#reading-percentiles)
- [Overflow handling](#overflow-handling)
- [Backend selection](#backend-selection)


## Loading

Load the public entry point:

```Ruby
require 'p99'
```

This loads `P99::Histogram` and selects the available implementation. The
active backend is available through `P99::IMPLEMENTATION`.


## Recording durations

Create an empty histogram and record durations in the supported units:

```Ruby
histogram = P99::Histogram.new

histogram.push_event_time_ns(150)
histogram.push_event_time_us(5)
histogram.push_event_time_ms(10)
histogram.push_event_time_s(1)
```

All recorded durations are converted to nanoseconds. Each `push_event_time_*`
method returns `true` when the duration is accepted and `false` when it cannot
be recorded.

Use `clear` to reset the histogram:

```Ruby
histogram.clear
```


## Reading statistics

The histogram exposes the number of recorded events and aggregate duration
statistics:

```Ruby
histogram.event_count
histogram.event_time_total
histogram.event_time_total_raw
histogram.min_event_time
histogram.max_event_time
histogram.has_overflowed?
```

The duration values are expressed in nanoseconds. The raw total is useful when
the normal total has entered the overflow state.


## Reading percentiles

Use the named methods for common percentiles:

```Ruby
histogram.value_at_p50
histogram.value_at_p90
histogram.value_at_p99
histogram.value_at_p99_9
```

For other percentile values, use `value_at_percentile` or query several
percentiles at once with `values_at_percentiles`. `fixed_percentiles` provides
the library's standard percentile set.

The result is an approximation in nanoseconds. The implementation uses 64
logarithmic power-of-two buckets and linearly interpolates within the selected
bucket, so results should be treated as estimates rather than exact samples.


## Overflow handling

The histogram tracks whether the running event-time total has overflowed.
Once an addition cannot be represented safely, subsequent duration pushes are
rejected and `has_overflowed?` reports `true`.

Call `clear` to return the histogram to its initial empty state.


## Backend selection

The loader prefers a native backend when one is available. Set
`P99_PURE_RUBY` to force the pure-Ruby implementation:

```Shell
P99_PURE_RUBY=1 ruby -e "require 'p99'; puts P99::IMPLEMENTATION"
```

The current release reports `"ruby"` through `P99::IMPLEMENTATION`. A
compatible C-extension backend is planned for a future release.


<!-- ########################### end of file ########################### -->
