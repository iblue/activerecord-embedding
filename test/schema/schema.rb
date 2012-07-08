# encoding: UTF-8
ActiveRecord::Schema.define do
  create_table "invoices", :force => true do |t|
    t.string   "recipient_email"
  end

  create_table "items", :force => true do |t|
    t.integer  "invoice_id"
    t.integer  "amount"
    t.string   "description"
    t.float    "value"
  end
end

