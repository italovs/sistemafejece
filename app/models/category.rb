class Category < ApplicationRecord
  has_many :post_categories
  has_many :tv_serie_categories

  has_many :tv_series, :through => :tv_serie_categories, :source => "tv_serie"
  has_many :seasons, :through => :tv_series
  has_many :season_posts, :through => :seasons
  has_many :posts, :through => :season_posts, :source => "post"
end
