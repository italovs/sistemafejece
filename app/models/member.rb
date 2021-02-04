class Member < ApplicationRecord
	# Include default devise modules. Others available are:
	# :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
	devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable

	belongs_to :junior_enterprise

	enum cargo: {
		desenvolvedor: 0,
		designer: 1,
		marketing: 2,
		gerente: 3,
		rh: 4
	}
end
