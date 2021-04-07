# frozen_string_literal: true

class ApplicationController < ActionController::Base
  def verifica_admin
    unless admin_signed_in?
      if member_signed_in?
        redirect_to member_root_path
      else
        redirect_to not_logged_member_root_path
      end
    end
  end

  def verificar_bloqueio_de_controller
    if controller_name == 'sessions' && resource_name == :member && admin_signed_in?
      redirect_to admin_root_path
    elsif controller_name == 'sessions' && resource_name == :admin && member_signed_in?
      redirect_to member_root_path
    end
  end
end
