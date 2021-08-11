# frozen_string_literal: true

class JuniorEnterprise < ApplicationRecord
  has_many :members
  has_many :posts
  has_many :tv_series

  before_destroy :change_series_and_posts_owner

  private

  def change_series_and_posts_owner
    @fejece_id = 0
    @posts = Post.where(owner_id: id)
    @posts.each do |post|
      post.owner_id = @fejece_id
      post.save
    end
  end

  def delete_members
    @members = Member.where(junior_enterprise_id: id)

    @members.destroy_all
  end
end
