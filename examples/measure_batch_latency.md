# p99.Ruby Example - **measure_batch_latency** <!-- omit in toc -->

## Summary

Example illustrating how to measure batch-operation latency with a monotonic
clock, record the elapsed duration in nanoseconds, and print fixed percentile
results.


## Source

See [measure_batch_latency.rb](./measure_batch_latency.rb).


## Execution

Run with the default of 20 simulated batches:

```bash
ruby examples/measure_batch_latency.rb
```

Set `P99_TRIES` to measure a different number of batches:

```bash
P99_TRIES=1000 ruby examples/measure_batch_latency.rb
```


## Representative output

The timing values vary by machine and scheduler. A short run produces output
like:

```text
Measuring 3 batch operations...
  batch 1: 3 items
  batch 2: 2 items
  batch 3: 2 items

Batch count: 3
Backend: ruby
Min latency: 258000 ns
Max latency: 398000 ns

Approximate percentiles:
  p50: 258000 ns
  p75: 262143 ns
  p90: 262143 ns
  p99: 262143 ns
```


<!-- ########################### end of file ########################### -->
