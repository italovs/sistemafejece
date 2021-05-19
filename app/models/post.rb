require 'open-uri'
class Post < ApplicationRecord
  attribute :sum_votes, :integer, default: 0
  attribute :votes, :integer, default: 0
  attribute :views, :integer, default: 0

  # post
  has_many :post_category, dependent: :destroy
  has_many :categories, through: :post_category
  belongs_to :junior_enterprise, foreign_key: 'owner_id'

  # video
  has_many :season_post, dependent: :destroy
  has_many :season, through: :season_post, source: 'season'
  has_many :tv_serie, through: :season, source: 'tv_serie'

  has_one_attached :poster_image # 300x444
  has_one_attached :banner_image # 1600x803
  validates :poster_image, content_type: ['image/jpg', 'image/png', 'image/jpeg']
  validates :banner_image, content_type: ['image/jpg', 'image/png', 'image/jpeg']

  enum kind: {
    post: 0,
    video: 1
  }

  before_destroy :delete_images
  after_commit :default_images, on: %i[create update]

  def rating
    votes = Vote.where(post_id: id)
    if votes.any?
      votes.average(:value).to_f.round(2)
    else
      -1
    end
  end

  def total_votes
    Vote.where(post_id: id).count
  end

  def vote_from_person(person, is_admin)
    votes = Vote.where(post_id: id, owner: person.id, admin: is_admin)
    if votes.any?
      votes.first.value.to_f.round(2)
    else
      0
    end
  end

  def vote_information(person, is_admin)
    {rating: rating, total_votes: total_votes, this_person_s_vote: vote_from_person(person, is_admin) }
  end

  def owner
    if video?
      tv_serie.owner_id
    else
      season_post.owner_id
    end
  end

  def default_images
    file = URI.open('https://storage.googleapis.com/farol-fejece/fotos/default_post_image.png')
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
end
