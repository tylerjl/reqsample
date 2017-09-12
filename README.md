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

## Features

- Weighted sampling for country of origin, user agents, and response codes to simulate real traffic.
- Usable in standalone command form or as a Ruby library.
- Ability to generate all traffic at once in bulk or streamed over time.
- Frequency and count of request events following a statistically normal distribution.

## Examples

Stream 5,000 log events to stdout with a tighter standard deviation:

```
reqsample stream --count 5000 --stdev 1
```

## Install

    $ gem install reqsample

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
