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
		votes = Vote.where(post_id: self.id)
		if votes.any?
			votes.average(:value).to_f.round(2)
		else
			0
		end
	end

	def total_votes
		Vote.where(post_id: self.id).count
	end

	def vote_from_person( person, is_admin )
		vote = Vote.where(post_id: self.id, owner: person.id, admin: is_admin)
		if votes.any?
			vote.first.value.to_f.round(2)
		else
			0
		end
	end

	def vote_information(person, is_admin)
		{rating: self.rating, total_votes: self.total_votes, this_person_s_vote: self.vote_from_person( person, is_admin) }
	end

end
