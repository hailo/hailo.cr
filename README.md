# 🔴 hailo.cr

[![License GPL 3](https://img.shields.io/badge/license-GPL_3-green.svg)](https://github.com/hailo/hailo.cr/blob/master/COPYING)
[![Travis CI](https://travis-ci.org/hailo/hailo.cr.svg?branch=master)](https://travis-ci.org/hailo/hailo.cr)

Hailo is a Markov chatterbot inspired by [MegaHAL](https://en.wikipedia.org/wiki/MegaHAL).

It is actually a port of the eponymous [Hailo Perl module](https://github.com/hailo/hailo).

The difference being that this one's written in [Crystal](https://crystal-lang.org/),
consists of less code, runs faster, and uses less memory. It also
drops support for multiple storage engines, sticking with SQLite only.

## Differences from classic MegaHAL

- Uses a space-efficient SQLite database to store the brain (saving 90%
  of the space)
- Quite fast at training against a large corpus
- Includes a server daemon
- Won't choke when the number of unique tokens passes the 64k mark ;)
- Sophisticated parser and formatter
  - Meaningfully tokenizes almost anything you'd encounter in a chatroom
    (Unicode, URLs, dates & times, quotes, abbreviations etc)
  - Intelligent handling of punctuation as prefix/postfix/infix tokens
  - Special consideration of fully-capitalized and partially-capitalized
    tokens rather than normalizing case and treating them identically
  - Outputs clean, properly capitalized sentences

## Installation

First, install [Crystal](https://crystal-lang.org/docs/installation/) along
with `libsqlite3-dev` and `libreadline-dev`. Then do:

```sh
git clone https://github.com/hailo/hailo.cr.git
cd hailo.cr
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

See the [API documentation](https://hailo.github.io/hailo.cr/Hailo.html)
for more information.

## Hacking

Running the tests is simple:

```sh
crystal spec
```

If you've saved a brain file with `hailo-cr --brain whatever.brain`, you can
easily inspect it since it's just a SQLite file:

```sh
sqlite3 whatever.brain
sqlite> .schema
sqlite> select * from token limit 10;
```

## Support

You can ask a question in the [issue tracker](https://github.com/hailo/hailo.cr/issues),
email me at hinrik.sig@gmail.com, or hit me up on FreeNode (#hailo).

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

See [`COPYING`](https://github.com/hailo/hailo.cr/blob/master/COPYING)
for the complete license.
