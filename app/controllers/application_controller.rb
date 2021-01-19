# frozen_string_literal: true

class ApplicationController < ActionController::Base

  def verifica_admin
    if !admin_signed_in?
      if member_signed_in?
        redirect_to member_root_path
      else
        redirect_to not_logged_member_root_path
      end
    end
  end
end
