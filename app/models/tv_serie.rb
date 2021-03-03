class TvSerie < ApplicationRecord
  has_many :seasons

  after_create :create_first_season

  #métodos
  def create_first_season
    Season.create(name: "Primeira Temporada", tv_serie_id: self.id)
  end
  #private
  private

end
