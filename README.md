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

**p99.Ruby** currently ships the **`P99`** root module and version metadata (`require 'p99'`). The low-overhead logarithmic histogram / percentile query surface present in the sibling **p99** libraries (fixed-size buckets, push duration, query p50 / p90 / p99 / …) is not yet implemented in this Ruby tree; see the **Related projects** links for the mature C and other-language APIs this gem is intended to mirror.


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
