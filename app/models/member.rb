class Member < ApplicationRecord
	# Include default devise modules. Others available are:
	# :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
	devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable

	belongs_to :junior_enterprise
	has_one_attached :profile_picture do |attachable|
		attachable.variant(combine_options:{gravity:'Center', crop: '100x100+0+0'})
		attachable.variant(combine_options:{gravity:'Center', crop: '300x300+0+0'})
	end
	validates :profile_picture, content_type: ["image/jpg","image/png","image/jpeg"]
	validates :profile_picture, size: {less_than: 5.megabytes}
	
	enum position: {
		desenvolvedor:0,
		designer: 1,
		marketing: 2,
		gerente: 3,
		rh: 4
	}
end
