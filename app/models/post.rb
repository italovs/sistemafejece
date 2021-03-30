class Post < ApplicationRecord
	attribute :sum_votes, :integer, default: 0
	attribute :votes, :integer, default: 0

	#post
	has_many :post_category

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

	after_commit :default_images, on: %i[create update]


	def rating
		votes = Vote.where(post_id: self.id)
		if votes.any?
			votes.average(:value).to_f.round(2)
		else
			"Não há avaliações"
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
	
	private

	def default_images
		file = URI.open('https://storage.googleapis.com/farol-fejece-test/fotos/default_post_image.png')
		unless poster_image.attached?
			poster_image.attach(io: file, filename: 'default_post_image.png', content_type: 'image/png')
		end
		unless banner_image.attached?
			banner_image.attach(io: file, filename: 'default_post_image.png', content_type: 'image/png')
		end
	end
end
