class SeasonPost < ApplicationRecord
  belongs_to :post
  belongs_to :season
end
