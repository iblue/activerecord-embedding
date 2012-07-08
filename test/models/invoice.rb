class Invoice < ActiveRecord::Base
  include ActiveRecord::Embedding

  embeds_many :items

  def total
    items.map{|i| i.amount * i.value}.compact.reduce(:+) || 0.0
  end
end

