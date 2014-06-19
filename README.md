# DotProperties [![Build Status](https://secure.travis-ci.org/mbklein/dot-properties.png)](http://travis-ci.org/mbklein/dot-properties)

Reads and writes [Java .properties files](http://en.wikipedia.org/wiki/.properties) like a champ.

* Intuitive, Hash-like access. Anywhere it makes sense to act like a Hash, it acts like a Hash.
* Won't clobber comments and blank lines (unless you want to).
* Will preserve original delimiters for each value (unless you normalize them).
* Supports all the delimiters (whitespace, `=`, `:`).
* Supports both comment prefixes (`#`, `!`).
* Supports expansion of inline `${property}` references.

## Installation

Add this line to your application's Gemfile:

    gem 'dot_properties'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install dot_properties

## Usage

    require 'dot_properties'

    # Load a .properties file
    props = DotProperties.load('sample.properties')

    # Get a value
    props['foo']

    # Set a value
    props['foo'] = 'bar'

    # Convert key/value pairs to a hash
    props.to_h

    # Or just let it act like a hash 
    props.each_pair { |key,value| puts "#{key} :: #{value}" }

    # Remove all comments/blanks/both
    props.strip_comments!
    props.strip_blanks!
    props.compact!

    # Write a .properties file
    File.open('output.properties','w') { |out| out.write(props.to_s) }

See the spec tests and fixture data for more examples.

## Known Issues

* Multiline values will be converted to single line on output

## History

- <b>0.1.3</b> - Explicitly require 'forwardable' (jruby / mri2.x compat) (from @billdueber)
- <b>0.1.2</b> - Improved escaping and Unicode (\uXXXX) support
- <b>0.1.1</b> - Fix mishandled keys with leading whitespace (#1)
- <b>0.1.0</b> - Initial release

## Copyright

Copyright (c) 2013 Michael B. Klein. See LICENSE.txt for further details.
