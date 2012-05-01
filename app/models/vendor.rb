class Vendor < ActiveRecord::Base
  include ImageMethods
  include Scope
  belongs_to :company
  has_and_belongs_to_many :users
  has_many :articles
  has_many :categories
  has_many :cost_centers
  has_many :customers
  has_many :groups
  has_many :images, :as => :imageable
  has_many :ingredients
  has_many :items
  has_many :options
  has_many :orders
  has_many :pages
  has_many :partials
  has_many :presentations
  has_many :quantities
  has_many :roles
  has_many :settlements
  has_many :tables
  has_many :roles
  has_many :taxes
  has_many :vendor_printers

  serialize :unused_order_numbers

  validates_presence_of :name

  accepts_nested_attributes_for :vendor_printers, :allow_destroy => true, :reject_if => proc { |attrs| attrs['name'] == '' }

  accepts_nested_attributes_for :images, :allow_destroy => true, :reject_if => :all_blank

  def image
    return self.images.first.image unless Image.count(:conditions => "imageable_id = #{self.id}") == 0 or self.images.first.nil?
    "/images/client_logo.png"
  end

  # aid and qid is the model id of Article or Quantity
  # d is the designator, a mix of model and it's id, so that we can have unique values in the HTML, e.g. 'q203' or 'a33'
  # n is the name of either Quantity or Article
  # p is the price of either ...
  # s is 'sort' and determins the position on the screen
  # q is a json-sub-object

  # JS returns additional attributes:
  # o is comment
  # c is count
  # t is array of options

  # resources.p is pending
  # resources.l is listing

  def resources
    categories = {}
    self.categories.each do |c|
      articles = {}
      c.articles.each do |a|
        quantities = {}
        a.quantities.each do |q|
          quantities.merge! q.id => { :aid => '', :qid => q.id, :d => "q#{q.id}", :pre => q.prefix, :post => q.postfix, :p => q.price, :s => q.position }
        end
        articles.merge! a.id => { :aid => a.id, :qid => '', :d => "a#{a.id}", :n => a.name, :p => a.price, :s => a.position, :q => quantities }
      end
      options = {}
      c.options.each do |o|
        options.merge! o.id => { :id => o.id, :n => o.name, :p => o.price }
      end
      categories.merge! c.id => { :id => c.id, :a => articles, :o => options }
    end
    resources = { :c => categories, :p => {}, :l => {} }
    return resources.to_json
  end

end