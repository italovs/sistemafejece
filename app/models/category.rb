# frozen_string_literal: true

class Category < ApplicationRecord
  has_many :post_categories
  has_many :tv_serie_categories

  has_many :tv_series, through: :tv_serie_categories, source: 'tv_serie'
  has_many :seasons, through: :tv_series
  has_many :season_posts, through: :seasons
  has_many :posts, through: :season_posts, source: 'post'

  before_destroy :delete_category_from_posts_and_series

  private

  def delete_category_from_posts_and_series
    @posts = PostCategory.where(category_id: id)
    @posts.destroy_all

    @tvserie = TvSerieCategory.where(category_id: id)
    @tvserie.destroy_all
  end
end
