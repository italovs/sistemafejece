# frozen_string_literal: true

class Activity < ApplicationRecord
  after_create :delete_day
  validates :quantity, presence: true

  private

  def delete_day
    Activity.first.delete if Activity.all.size > 30
  end
end
