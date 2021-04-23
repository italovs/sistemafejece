class JuniorEnterprise < ApplicationRecord
	has_many :members
	has_many :posts
	has_many :tv_series
end
