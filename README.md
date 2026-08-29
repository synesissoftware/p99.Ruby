# p99.Ruby <!-- omit in toc -->

Low-cost generation of performance percentiles (p50, p90, p99, p99.9, etc.), for Ruby

![Language](https://img.shields.io/badge/Ruby-CC342D?style=flat&logo=ruby&logoColor=white)
[![License](https://img.shields.io/badge/License-BSD_3--Clause-blue.svg)](https://opensource.org/licenses/BSD-3-Clause)
[![GitHub release](https://img.shields.io/github/v/release/synesissoftware/p99.Ruby.svg)](https://github.com/synesissoftware/p99.Ruby/releases/latest)
[![Last Commit](https://img.shields.io/github/last-commit/synesissoftware/p99.Ruby)](https://github.com/synesissoftware/p99.Ruby/commits/master)
[![Gem Version](https://badge.fury.io/rb/p99-ruby.svg)](https://badge.fury.io/rb/p99-ruby)
[![Ruby](https://github.com/synesissoftware/p99.Ruby/actions/workflows/ruby.yml/badge.svg)](https://github.com/synesissoftware/p99.Ruby/actions/workflows/ruby.yml)


## Table of Contents <!-- omit in toc -->

- [Introduction](#introduction)
- [Installation](#installation)
- [Components](#components)
  - [`P99::Histogram`](#p99histogram)
- [Examples](#examples)
- [Project Information](#project-information)
  - [Where to get help](#where-to-get-help)
  - [Contribution guidelines](#contribution-guidelines)
  - [Dependencies](#dependencies)
    - [Development Dependencies](#development-dependencies)
  - [Related projects](#related-projects)
  - [License](#license)


## Introduction

**p99** is a lightweight, low-overhead library designed for generating real-time performance percentiles in high-frequency or latency-sensitive environments.

**p99.Ruby** is the **Ruby** implementation.


## Installation

Install via **gem** as in:

```
gem install p99-ruby
```

or add it to your `Gemfile`.

Use via **require**, as in:

```Ruby
require 'p99'
```


## Components


### `P99::Histogram`

Low-cost, fixed-size histogram for recording event durations (nanoseconds and
common larger units) and querying high-resolution percentiles (p50, p90, p99,
and beyond).

This release provides a **pure-Ruby** implementation. A C-extension backend
(with automatic fallback) is planned.

See the [Histogram component guide](./docs/components/histogram.md) for
loading, recording, statistics, percentile, and backend details. The
[generated API reference](./docs/reference/README.md) provides the complete
source-level method documentation.

The [task-oriented guides](./docs/guides/README.md) provide practical
workflows for recording and reading percentiles.

```Ruby
require 'p99'

h = P99::Histogram.new
h.push_event_time_ns(150)
h.push_event_time_us(5)
h.push_event_time_ms(10)

h.event_count          # => 3
h.value_at_p99         # => approximated duration in nanoseconds
P99::IMPLEMENTATION    # => "ruby" (or "c" when a native backend is present)
```

Force the pure-Ruby backend (for debugging or CI):

```bash
P99_PURE_RUBY=1 ruby -e "require 'p99'; puts P99::IMPLEMENTATION"
```


## Examples

See [**EXAMPLES.md**](./EXAMPLES.md) for the full list. The primary
demonstration is [**build_histogram**](./examples/build_histogram.md):

```bash
ruby examples/build_histogram.rb
P99_TRIES=1000 ruby examples/build_histogram.rb
```


## Project Information


### Where to get help

[GitHub Page](https://github.com/synesissoftware/p99.Ruby "GitHub Page")


### Contribution guidelines

Defect reports, feature requests, and pull requests are welcome on https://github.com/synesissoftware/p99.Ruby.


### Dependencies

* \<none>


#### Development Dependencies

* [**xqsr3**](https://github.com/synesissoftware/xqsr3/)


### Related projects

* [**p99**](https://github.com/synesissoftware/p99/)
* [**p99.Go**](https://github.com/synesissoftware/p99.Go/)
* [**p99.NET**](https://github.com/synesissoftware/p99.NET/)
* [**p99.Python**](https://github.com/synesissoftware/p99.Python/)
* [**p99.Rust**](https://github.com/synesissoftware/p99.Rust/)
* [**p99.Zig**](https://github.com/synesissoftware/p99.Zig/)


### License

**p99.Ruby** is released under the 3-clause BSD license. See [LICENSE](./LICENSE) for details.


<!-- ########################### end of file ########################### -->
