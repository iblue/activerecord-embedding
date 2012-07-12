# activerecord-embedding

Adds MongoDB style `embeds_many` to `ActiveRecord`.

## Example

```
class Invoice < ActiveRecord::Base
  include ActiveRecord::Embedding

  embeds_many :items
end
```

Now you can do all the magic `ActiveRecord` does not support natively.

```
@invoice = Invoice.new
@invoice.attributes = {items: [{description: "Some fancy ORM",                       value: 10.00},
                               {description: "When ActiveRecord does what you want", value: "priceless"}]}
```

You can also change your items and ActiveRecord will mark them for destruction and destroy them later.

```
# Imagine an Invoice with two items...
@invoice.find(1)
Items.count           # => 2
@invoice.items.length # => 2

# When we change the items to zero...
@invoice.attributes = {items: []}
@invoice.items.length # => 0
Items.count           # => 2 (because not saved yet)

# It will write the changes after we save them
@invoice.save!
@invoice.items.length # => 0
Items.count           # => 0
```

Hopefully someday there will be native support for this in ActiveRecord.

## Usage

Add the gem to your `Gemfile`

```
gem "activerecord-embedding"
```

Then use in your models.
```
class Invoice < ActiveRecord::Base
  include ActiveRecord::Embedding

  embeds_many :items
end
```

Remember to `include ActiveRecord::Embedding`!

## Development

There are some pretty evil hacks in the source. Feel free to fix them and send
me a pull request. Please comment your code and write tests. You can run the
test suite with `rake`. Please do not modify the `version.rb` file.

## Release

(Because my short time memory lasts for less than 23 ignoseconds, I need to write this down)

```
# Remember to run the tests and to bump the version
gem build activerecord-embedding.gemspec
gem push activerecord-embedding-$version.gem
```

## Credits

I must admit that this code is mostly based on a gist of netzpirat.  Michael,
you did a great job! I just improved your code, added a few really really ugly
hacks to work around some strange ActiveRecord behavior and wrote some tests.

