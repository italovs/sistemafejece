class Category < ApplicationRecord
  has_many :post_categories
  has_many :tv_serie_categories

  #has_many :file_posts, class_name: "post", through: :post_categories
  has_many :file_posts, through: :post_category, source: "post_id"
end
