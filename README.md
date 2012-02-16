MonospaceTextFormatter
======================

MonospaceTextFormatter is a Ruby Gem that formats monospaced text into a **line or visual box** of defined **width** and **height** boundaries (expressed in number of characters), by wrapping and/or truncating the text, and filling remaining area with spaces (or custom characters) so that it forms a rectangular block. It **doesn't split words** unless they are longer than the width boundary. It also applies **horizontal** and **vertical alignment** to the text. All these attributes are customizable and optional.

* **MonospaceTextFormatter::Line** class formats a single-line text;

* **MonospaceTextFormatter::Box** class formats multiple-line text.

Usage examples
--------------

Note: All the following attributes can also be provided in Hash as the second argument for the constructor.

### MonospaceTextFormatter::Line

The `line` object for the following examples:

```ruby
  line = MonospaceTextFormatter::Line.new("This is some text.")
```

```ruby
  line.to_s
   => "This is some text."
```

* `width` (a number of characters)

```ruby
  line.width = 20
  line.to_s
   => "This is some text.  "

  line.width = 16
  line.to_s
   => "This is some ..."
```

* `omission`

```ruby
  line.omission = " [...]"
  line.to_s
   => "This is [...]   "
```

* `align` (available options: `:left` _(default)_, `:center` and `:right`)

```ruby
  line.align = :right
  line.to_s
   => "   This is [...]"
```

* `fill`

```ruby
  line.fill = "-"
  line.to_s
   => "---This is [...]"
```

### MonospaceTextFormatter::Box

The `box` object for the following examples:

```ruby
  box = MonospaceTextFormatter::Box.new("First line.\nAnd second, a little bit longer line.")
```

```ruby
  box.to_s
   => "First line.                          \nAnd second, a little bit longer line."

  box.lines
   => ["First line.                          ",
       "And second, a little bit longer line."]
```

* `width` (a number of characters)

```ruby
  box.width = 20
  box.lines
   => ["First line.         ",
       "And second, a little",
       "bit longer line.    "]
```

* `height` (a number of lines)

```ruby
  box.height = 5
  box.lines
   => ["First line.         ",
       "And second, a little",
       "bit longer line.    ",
       "                    ",
       "                    "]

  box.height = 2
  box.lines
   => ["First line.         ",
       "And second, a ...   "]
```

* `omission`

```ruby
  box.omission = " [...]"
  box.lines
   => ["First line.         ",
       "And second, a [...] "]
```

* `align` (available options: `:left` _(default)_, `:center` and `:right`)

```ruby
  box.align = :center
  box.lines
   => ["    First line.     ",
       "And second, a [...] "]
```

* `valign` (available options: `:top` _(default)_, `:middle` and `:bottom`)

```ruby
  box.height = 5
  box.valign = :bottom
  box.lines
   => ["                    ",
       "                    ",
       "    First line.     ",
       "And second, a little",
       "  bit longer line.  "]
```

* `fill`

``` ruby
  box.fill = "#"
  box.lines
   => ["####################",
       "####################",
       "####First line.#####",
       "And second, a little",
       "##bit longer line.##"]
```

More can be found in **RSpec examples**.

Installation
------------

As a Ruby Gem, MonospaceTextFormatter can be installed either by running

```bash
  gem install monospace_text_formatter
```

or adding

```ruby
  gem "monospace_text_formatter"
```

to the Gemfile and then invoking `bundle install`.

License
-------

License is included in the LICENSE file.
