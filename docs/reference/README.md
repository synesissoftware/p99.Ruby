# p99.Ruby Generated API Reference <!-- omit in toc -->

The generated API reference is produced by RDoc from the Ruby source
documentation comments. It complements the authored Histogram documentation:

* [`docs/components/histogram.md`](../components/histogram.md) explains the
  component's loading, recording, statistics, percentile, and backend APIs;
* generated `doc/` explains the complete public Ruby API;


## Generate the reference

From the project directory, run:

```Shell
./generate_rdoc.sh
```

The script removes previous generated output and writes the new reference to
`doc/` by default. Use `--pwd` to operate in the caller's current directory,
or set `SIS_RDOC_DOC_DIR` to choose another generated-document directory.
Generated files are build output and should not be edited by hand.

To check that every documentable API entity has RDoc documentation, run:

```Shell
./generate_rdoc.sh --coverage-report
```


## Reading the reference

Use the generated namespace and method pages for exact signatures and
source-level API details. Start with the authored component documentation when
deciding how to use `P99::Histogram`, then use RDoc to inspect the complete
method surface.


<!-- ########################### end of file ########################### -->
