class Member < ApplicationRecord
	# Include default devise modules. Others available are:
	# :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
	devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable

	belongs_to :junior_enterprise
	has_one_attached :profile_picture do |attachable|
		attachable.variant :thumb, resize:"100x100"
		attachable.variant :mediun, resize: "300x300"
	end
	validates :profile_picture, content_type: ['image/jpg','image/png','image/jpeg']
	validates :profile_picture, size:{less_than: 5.megabytes}
	#has_attached_file :picture, styles: { medium: "300x300#", small: "30x30#"}, default_url: "/assets/:style/user.png"
	#validates_attachment_content_type :picture, content_type: /\Aimage\/.*\z/

	enum position: {
		desenvolvedor: 0,
		designer: 1,
		marketing: 2,
		gerente: 3,
		rh: 4
	}
end
