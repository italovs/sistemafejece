class Post < ApplicationRecord
	attribute :sum_votes, :integer, default: 0
	attribute :votes, :integer, default: 0

	#post
	has_one :post_category
	
	#video
	has_one :season_post
	has_one :season, through: :season_post, source: "season"
	has_one :tv_serie, through: :season, source: "tv_serie"

	
	
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
			"Não há avaliaçẽos"
		end
	end

	def total_votes
		Vote.where(post_id: self.id).count
	end

	def vote_from_person( person, is_admin )
		votes = Vote.where(post_id: self.id, owner: person.id, admin: is_admin)
		if votes.any?
			votes.first.value.to_f.round(2)
		else
			0
		end
	end

	def vote_information(person, is_admin)
		{rating: self.rating, total_votes: self.total_votes, this_person_s_vote: self.vote_from_person( person, is_admin) }
	end

	def owner
		if self.video?
			self.tv_serie.owner_id
		else
			self.season_post.owner_id
		end
	end

end
