require 'rubygems'
require 'bundler'
Bundler.setup

require 'debugger'

require 'test/unit'
require 'active_record'
require 'active_record/base'
require 'logger'

require 'activerecord-embedding'

require 'models/invoice'
require 'models/item'

ActiveRecord::Base.establish_connection(
  :adapter => "sqlite3",
  :database  => "/tmp/test.db"
)
load "schema/schema.rb"


# Make sure we see whats happening
ActiveRecord::Base.logger = Logger.new(STDOUT)

class MainTest < Test::Unit::TestCase
  def test_embedding
    # Build a new invoice, do not save anything, exists in memory only
    puts "--- Should not issue a query"
    @invoice = Invoice.new
    @invoice.attributes = {items: [{amount: 1, description: "Item 1", value: 10.00}, {amount: 2, description: "Item 2", value: 8.00}]}
    assert_equal 0, Invoice.count
    assert_equal 0, Item.count
    assert_equal 26.00, @invoice.total
    puts "   end"

    # Create everything, make sure it gets saved to the database
    puts "--- Should INSERT 1 invoice and 2 items"
    @invoice.save!
    assert_equal 1, Invoice.count
    assert_equal 2, Item.count
    assert_equal ["Item 1", "Item 2"], Item.all.map(&:description)
    assert_equal 26.00, @invoice.total
    puts "   end"

    # Change attributes, make sure it exists in memory only and does not get
    # saved to the database
    puts "--- Should not issue a query"
    @invoice.attributes = {items: [{amount: 1, description: "Item 3", value: 10.00}]}
    assert_equal 1, Invoice.count
    assert_equal 2, Item.count
    assert_equal ["Item 1", "Item 2"], Item.all.map(&:description)
    assert_equal 10.00, @invoice.total # But the total value in memory should change
    puts "   end"

    # Now save changes to database.
    puts "--- Should DELETE 2 items, INSERT 1 item"
    @invoice.save!
    assert_equal 1, Invoice.count
    assert_equal 1, Item.count
    assert_equal ["Item 3"], Item.all.map(&:description)
    assert_equal 10.00, @invoice.total # Total value in memory should stay the same
    puts "   end"

    # Delete everything, make sure it's gone.
    puts "--- Should DELETE 1 item, DELETE 1 invoice"
    @invoice.destroy
    assert_equal 0, Invoice.count
    assert_equal 0, Item.count
    puts "   end"
  end
end
