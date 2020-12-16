# frozen_string_literal: true

class AdministrativeController < ApplicationController
  before_action :authenticate_admin!
  def index
  end
end
