class Admin < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :recoverable, :rememberable, :validatable

  has_attached_file :picture, styles: { medium: "300x300>", small: "30x30#" }, default_url: "assets/:style/user.png"
  validates_attachment_content_type :picture, content_type: /\Aimage\/.*\z/
  
end
