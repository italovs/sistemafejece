require 'open-uri'
class TvSerie < ApplicationRecord
  has_many :seasons, dependent: :destroy

  after_create :create_first_season
  before_destroy :delete_images

  has_many :tv_serie_category, dependent: :destroy
  has_many :categories, through: :tv_serie_category, source: 'categories'

  has_one_attached :poster_image # 300x444
  has_one_attached :banner_image # 1600x803
  validates :poster_image, content_type: ['image/jpg', 'image/png', 'image/jpeg']
  validates :banner_image, content_type: ['image/jpg', 'image/png', 'image/jpeg']

  after_commit :default_images, on: %i[create update]

  # métodos
  def create_first_season
    Season.create(order: 1, tv_serie_id: id)
  end

  def default_images
    file = URI.open('https://storage.googleapis.com/farol-fejece-test/fotos/default_post_image.png')
    unless poster_image.attached?
      poster_image.attach(io: file, filename: 'default_post_image.png', content_type: 'image/png')
    end
    unless banner_image.attached?
      banner_image.attach(io: file, filename: 'default_post_image.png', content_type: 'image/png')
    end
  end

  def delete_images
    poster_image.purge
    banner_image.purge
  end

  # private
end
