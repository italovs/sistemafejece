class Admin < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :recoverable, :rememberable, :validatable, :registerable
  before_destroy :delete_images

  has_one_attached :profile_picture do |attachable|
    attachable.variant :thumb, resize:"100x100"
    attachable.variant :mediun, resize: "300x300"
  end
  def delete_images
    profile_picture.purge
  end
  # has_attached_file :picture, styles: { medium: "300x300>", small: "30x30#" }, default_url: "assets/:style/user.png"
  # validates_attachment_content_type :picture, content_type: /\Aimage\/.*\z/
end
