class Season < ApplicationRecord
  belongs_to :tv_serie
  has_many :season_posts, dependent: :destroy
  has_many :posts, through: :season_posts, source: 'post'

  before_destroy :reorder_seasons

  def reorder_seasons
    byebug
    unless order == Season.where(tv_serie_id: tv_serie_id).maximum('order')
      @seasons = Season.where(tv_serie_id: tv_serie_id)
      @next_seasons = []
      @seasons.each do |season|
        byebug
        if season.order > order
          @next_seasons << season
        end
      end

      @next_seasons.each do |season|
        season.order = season.order - 1
        season.save
      end
      byebug
    end
  end
end
