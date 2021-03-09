class Season < ApplicationRecord
  belongs_to :tv_serie
  has_many :season_posts

  has_many :posts, :through => :season_posts, :source => "post"
end
