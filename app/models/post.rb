class Post < ApplicationRecord
  attribute :sum_votes, :integer, default: 0
  attribute :votes, :integer, default: 0

  has_one :post_category
  has_one_attached :poster_image #300x444
  has_one_attached :banner_image #1600x803
  validates :poster_image, content_type: ["image/jpg","image/png","image/jpeg"]
  validates :banner_image, content_type: ["image/jpg","image/png","image/jpeg"]
  enum kind: {
		post: 0,
		video: 1
	}

  def rating
    (self.sum_votes/self.votes).to_f.round(2)
  end
end
