# Patterns

Patterns are the building blocks of your system. A pattern may be of any
scope and size; it may describe anything from a single file on disk to
an entire application server. Patterns are designed to be reusable and
composable. A good pattern should be small in scope and easily
customizable.

## Using a pattern

The simplest way to use a pattern is within a
[blueprint](BLUEPRINTS.md). A blueprint is just a pattern that executes
with a special scope. Let's use the builtin `File` pattern to create a
file on disk.

    add Config::Patterns::File do |f|
      f.path = "/tmp/hello"
      f.content = "hello world"
    end

Here we call the `add` method with the class of the pattern. Providing a
block lets us configure the pattern's [attributes](#attributes). That's
it. When this pattern is executed, it will write a file to `/tmp/hello`
with the content `hello world`.

### Helpers

The syntax above is the low level form. For common patterns, Config
provides shortcuts. File is a very common case, so this is the form you
will generally see.

    file "/tmp/hello" do |f|
      f.content = "hello world"
    end

Helpers are defined in `Config::Patterns`; Simply define methods in that
module to add your own. As a rule, only the most common patterns should
have helpers. It is standard practice to use the `add <class>` form for
your own patterns.

## Important qualities

Patterns have several important qualities. Understanding the design
philosophy will help you write your own.

## Idempotency

A pattern must be idempotent. If a pattern is executed with the same
inputs on the same filesystem it should cause no change (not even a
modified `mtime`).

## Uniqueness, Equality and Conflict

Since patterns may use other patterns, the full set of patterns in use
for a complex configuration can be rather large. In order to reduce
confusion, Config requires that each instance of a pattern be either
equal or unique. Some examples will explain this best.

The following two patterns are *unique* because they manage different
files.

    file "/tmp/file1" do |f|
      f.content = "hello"
    end
    file "/tmp/file2" do |f|
      f.content = "goodbye"
    end

The following two patterns are *equal* because they manage the same file
in the exact same way. Since patterns are idempotent, there is no harm
here. Config optimizes this case by marking the second pattern as
*skipped* and does not execute it.

    file "/tmp/file1" do |f|
      f.content = "hello"
    end
    file "/tmp/file1" do |f|
      f.content = "hello"
    end

The following two patterns are *in conflict* because they manage the
same file, but specify different content. If this situation is detected,
Config throws an error before any execution occurs.

    file "/tmp/file1" do |f|
      f.content = "hello"
    end
    file "/tmp/file1" do |f|
      f.content = "goodbye"
    end

See [attributes](#attributes) to learn how to implement equality in your
own patterns.

## Reversible

A pattern must be reversible. That is, it must know how to clean up
after itself. For example, the `File` pattern knows how to create a file
on disk, but it also knows how to delete it. Your patterns, no matter
how complex, should be just as smart.

## Writing your own

A pattern is implemented as a Ruby class and stored in
`patterns/<topic>/<name>.rb`. Notice that patterns are grouped by the
`<topic>` they are part of. For example, if you are writing a web
server, you might have a topic of `nginx`, with two patterns: `service`
and `website`. `service` would install and run the nginx server, while
`website` could be used multiple times to configure different virtual
hosts. Config makes it easy to generate a sample pattern.

    config-create-pattern <topic> <name>

The result of this command is a file that might look something like
this.

    class Nginx::Website < Config::Pattern

      desc "The name"
      key  :name

      desc "The value"
      attr :value

      def call
        # add patterns here
      end
    end

There are a few things going on here. First note that a pattern is a
subclass of `Config::Pattern`. Every pattern you write should inherit
from `Config::Pattern`.

### Attributes

The example above defines two attributes. Attributes are variables that
must be defined in order to use the pattern. If any attribute is
undefined, Config will raise an error.

    desc "The name"
    key  :name

    desc "The value"
    attr :value

The attributes API has three methods.

  * `desc` Each attribute *must* have a description. Config will throw
    an error if any attribute is not documented.
  * `attr` Define an attribute. A Ruby Symbol is expected. Defining an
    attribute creates both a reader and a writer method (here, `#value`
    and `#value=`).
  * `key` Define a *key* attribute. A key attribute is like an attribute
    but makes up the *primary key* of the pattern. This key is used to
    define equality. A pattern may have zero or more keys.

Both `key` and `attr` may take a second argument, the default value.

    desc "Name of the pattern"
    key :name, "joe"

    desc "A sample value"
    key :value, "whee"

If an attribute defines a default value, it need not be set by the
caller. **Important:** this includes `nil`. If `nil` is an acceptable
value for the attribute, you must declare it as the default.

### Calling other patterns

Most patterns you write will call other patterns, and you do that
within the `call` method. You may (and are encouraged) to pass values
from this patterns' attributes down to children patterns. Following this
approach results in clear data flow and better reuse.

    def call
      add MyTopic::AnotherPattern do |p|
        p.message = value
      end
    end

The cal API has one method, plus helpers.

  * `add` Pass the class of a pattern and receive a block with an
    instance of the class.
  * `Config::Patterns` any helpers are available.

### Manipulation

In order to manipulate the system, config requires that you implement
two methods.

  * `create` Alter the node. This method is called whenever the pattern
    is executed.
  * `destroy` Reverse the alteration. This method is called when the
    pattern has been removed since the last execution. In this way,
    Config automatically cleans up after you. Simply remove a pattern
    from your code and on the next execution that pattern will run one
    last time to clean itself up.

### Identification

Config's logging system is one the most important tools to understand
what's happening on your nodes. You may specify how your pattern appears
in that output.

The identification API has two methods.

  * `describe` Change the basic description.
  * `to_s` Change the full description.

The default implementation of `#to_s` includes the class name and the
key attributes.

    pattern.to_s
    # => [File path:"/var/log/nginx.log"]

Override `describe` to change what's within the square brackets.

    def describe
      "A file at #{path}"
    end

    pattern.to_s
    # => [A file at /var/log/nginx.log]

Override `to_s` to change the full description.

    def to_s
      "<#{path}>
    end

    # => </var/log/nginx.log>

