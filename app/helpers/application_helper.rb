# frozen_string_literal: true

module ApplicationHelper

  def logout_path
    if member_signed_in?
      destroy_member_session_path
    elsif admin_signed_in?
      destroy_admin_session_path
    end
  end
end
