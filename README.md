# 🔴 hailo.cr

[![License GPL 3][badge-license]][copying]
[![Travis CI][badge-travis-ci]][travis-ci]

Hailo is a Markov chatterbot inspired by [MegaHAL][megahal].

It is actually a port of the eponymous [Hailo Perl module][hailo].

The difference being that this one's written in [Crystal][crystal],
consists of less code, runs faster, and uses less memory. It also
drops support for multiple storage engines, sticking with SQLite only.

## Installation

First, install [Crystal][install-crystal]. Then do:

```sh
git clone https://github.com/hailo/hailo-cr.git
cd hailo-cr
shards install
crystal build bin/hailo-cr.cr --release
```

This gives you a `hailo-cr` binary that you can run.

## Usage

Use the command line interface (`hailo-cr`), or use Hailo in your code:

```crystal
require "hailo"

hailo = Hailo.new("test.sqlite")
puts hailo.learn_and_reply("oh hi there")
```

## Support

You can ask a question in the [issue tracker][issues], email me at
hinrik.sig@gmail.com, or hit me up on FreeNode (#hailo).

## Contribute

Pull requests are welcome.

## License

hailo.cr is free software: you can redistribute it and/or modify it
under the terms of the GNU General Public License as published by the
Free Software Foundation, either version 3 of the License, or (at your
option) any later version.

hailo.cr is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
Public License for more details.

See [`COPYING`][copying] for the complete license.

[badge-license]: https://img.shields.io/badge/license-GPL_3-green.svg
[badge-travis-ci]: https://travis-ci.org/hailo/hailo.cr.svg?branch=master
[travis-ci]: https://travis-ci.org/hailo/hailo.cr
[megahal]: https://en.wikipedia.org/wiki/MegaHAL
[hailo]: https://github.com/hailo/hailo
[crystal]: https://crystal-lang.org/
[install-crystal]: https://crystal-lang.org/docs/installation/
[api-docs]: https://hailo-cr.readthedocs.io/en/latest/
[issues]: https://github.com/hailo/hailo.cr/issues
[COPYING]: https://github.com/hailo/hailo.cr/blob/master/COPYING
