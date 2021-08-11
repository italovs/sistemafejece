# frozen_string_literal: true

class TvSerieCategory < ApplicationRecord
  belongs_to :tv_serie
  belongs_to :category
end
