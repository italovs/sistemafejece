# frozen_string_literal: true

class AdministrativeController < ApplicationController
  layout 'administrative'
  include ApplicationHelper
  def index
  end

  def members_validation
    @directors = Member.where(validated: true)
    @not_yet_directors = Member.where(validated: nil)
  end

  def change_member_validation
    membro = Member.find(params[:id])
    membro.validated = params[:status]
    ActiveRecord::Base.transaction do
      membro.save
      render json: [msg: "Sucesso"]
    end

    rescue ActiveRecord::RecordInvalid
      render json: [msg: "Erro"]
  end
end
