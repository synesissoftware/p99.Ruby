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


<!-- ########################### end of file ########################### -->
