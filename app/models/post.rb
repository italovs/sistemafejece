class Post < ApplicationRecord
  attribute :rating, :float, default: 0
  belongs_to :member, class_name: "member", foreign_key: "member_id", optional: true
end
