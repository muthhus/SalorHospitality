class Company < ActiveRecord::Base
  has_many :users
  has_many :vendor_printers
  serialize :unused_order_numbers

  accepts_nested_attributes_for :vendor_printers, :allow_destroy => true, :reject_if => proc { |attrs| attrs['name'] == '' }

  def logo=(data)
    write_attribute :content_type, data.content_type.chomp
    write_attribute :image, data.read
  end
end
