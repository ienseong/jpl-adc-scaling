# J5 Ruby Library

This directory provides a set of common classes for implementing J5 ruby
applications.

## Contents

### Logger

The logger class provides consistent messaging across all J5 ruby application.

#### Features

* Messages can be strings or objects
* Adjustable verbosity level
* Seven report levels
* Per-level message counts
* Error and fatal levels are sent to stderr

#### Usage

Initialize:

```ruby
@logger = JF::Logger.get(
  name: "myapp"
)
```

Report:

```ruby
@logger.info "hello world"

@logger.error "uh oh"
```

## Tests

All portions of the J5 Ruby Library must have a test.

### Running

Run the tests using:

```sh
$ rake test
```
