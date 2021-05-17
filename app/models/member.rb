class Member < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable,
    :registerable,
    :recoverable,
    :rememberable,
    :validatable,
    :confirmable

  attribute :name, :string, default: ''
  encrypts :email, migrating: true

  before_create :director
  before_destroy :delete_images

  belongs_to :junior_enterprise
  has_one_attached :profile_picture do |attachable|
    attachable.variant(combine_options: {gravity: 'Center', crop: '100x100+0+0'})
    attachable.variant(combine_options: {gravity: 'Center', crop: '300x300+0+0'})
  end
  validates :profile_picture, content_type: ['image/jpg', 'image/png', 'image/jpeg']
  validates :profile_picture, size: {less_than: 5.megabytes}

  enum position: {
    Consultor: 0,
    Gerente: 1,
    Coordenador: 2,
    Diretor: 3
  }

  def delete_images
    profile_picture.purge
  end

  def director
    self.validated = if position == "Diretor"
                       nil
                     else
                       0
                     end
  end
end
