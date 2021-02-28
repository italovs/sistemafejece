class Post < ApplicationRecord
  attribute :sum_votes, :integer, default: 0
  attribute :votes, :integer, default: 0

  enum kind: {
		post: 0,
		video: 1
	}


  def rating
    (self.sum_votes/self.votes).to_f.round(2)
  end
end
