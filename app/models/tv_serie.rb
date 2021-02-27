class TvSerie < ApplicationRecord
  has_many :seasons
  

  after_create :first_season

  #métodos
  def first_season
    Season.create(name: "Primeira Temporada", tv_serie_id: self.id)
  end
  #private
  private

end
