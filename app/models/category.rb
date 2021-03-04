class Category < ApplicationRecord
  has_many :post_categories
  has_many :tv_serie_categories

end
