# reqsample

* [Homepage](https://rubygems.org/gems/reqsample)
* [Documentation](http://rubydoc.info/gems/reqsample/frames)

## Description

`reqsample` is a utility to generate somewhat-realistic public HTTP traffic. If you've ever needed a large corpus of Apache or nginx logs to test geoip processing, a Logstash pipeline, or as the source for a demo; this utility is for you.

Data is sampled from publicly available data (sources noted in the [credits](#credits) section) and, whenever possible, the frequency of various datasets is observed and reflected in the random data. For example, Chrome will appear frequently in the `User-Agent` string since it is a common browser, and the most common source IPs originate from China due to the high amount of traffic observed from the country.

Note that fine-tuning the generation scheme requires munging with the normal distribution curve and a few other tricky parameters, but usable defaults are used out-of-the-box.

### Quickstart

Generate 1,000 combined Apache log-formatted log entries, spanning the last 24 hours which peak 12 hours ago, and print them all to stdout:

```shell
$ gem install reqsample
$ reqsample
```

See `reqsample help` for a list of commands, flags, and options.

## Features

- Weighted sampling for country of origin, user agents, and response codes to simulate real traffic.
- Usable in standalone command form or as a Ruby library.
- Ability to generate all traffic at once in bulk or streamed over time.
- Frequency and count of request events following a statistically normal distribution.

There are several different parameters that can be changed to modify how data is generated. In general:

- A number of logs to be generated over a given period needs to be chosen, which by default is 1,000.
- These many log events are generated over a normal distribution curve, with a configurable peak, standard deviation, and time cutoff - defaults are chosen with the assumption that you want to generate 1,000 logs over the previous 24 hours.
  - The peak is 12 hours ago by default.
  - The standard deviation is set to 4 by default, which translates to 4 hours in the logic of the random generation.
  - The normal distribution of log data is truncated at 12 hours by default, which means all logs will fall within some timestamp within the past 24 hours.

## Examples

There are two methods to use `reqsample`, either through the installed executable or as a library.

### Command-Line Utility

Stream 5,000 log events to stdout with a tighter standard deviation:

```
reqsample stream --count 5000 --stdev 1
```

### Ruby Library

The `ReqSample::Generator` class needs to be instantiated first, which parses and sets up several enumerables from which values will be sampled.

```ruby
gen = ReqSample::Generator.new
```

The `produce` method is the central way to generate log values:

```ruby
gen.produce
```

Will return an array of logs with the previously mentioned parameters. If a block is given to the `produce` method, the results will instead be streamed to the block by yielding each log event, simulating live incoming traffic.

## Install

```shell
$ gem install reqsample
```

## Development

Standard bundler practices are used, setup your environment with `bundle install` and use `bundle exec rake test` to run the still-incomplete test suite.

Note that all of the source data is retrieved with rake tasks and vendored into the final library to avoid continually retrieving and parsing sources. See `rake -T` for what the tasks are and potentially re-run them if needed.

## Credits

- Country IP Addres Ranges
  - http://www.nirsoft.net/countryip/
- Country internet connectivity stats
  - https://en.wikipedia.org/wiki/List_of_countries_by_number_of_Internet_users
- User-Agents
  - https://techblog.willshouse.com/2012/01/03/most-common-user-agents/

## Copyright

Copyright (c) 2017 Tyler Langlois

See LICENSE.txt for details.
