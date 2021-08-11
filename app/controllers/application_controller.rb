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

  def activity_couter_update
    activity = Activity.last
    Activity.create(quantity: 1) if activity == nil
    if activity.created_at.day == Time.zone.today.day
      activity.quantity += 1
      activity.save
    else
      Activity.create(quantity: 1)
    end
  end

  def verify_onwership(object)
    if admin_signed_in?
      object.owner_id.zero?
    elsif current_member.validated?
      object.owner_id == current_member.junior_enterprise_id
    else
      false
    end
  end

  def direction_notification
    @flag = 0

    Member.all.each do |member|
      @flag += 1 if member.validated.nil?
    end
  end

  def user_tv_series
    @tv_series = if admin_signed_in?
                   TvSerie.where(owner_id: 0).select(:id, :name)
                 else
                   TvSerie.where(owner_id: current_logged_user.junior_enterprise_id).select(:id, :name)
                 end
  end

  def check_if_user_is_director_or_is_admin
    if member_signed_in? && !current_member.validated?
      redirect_back(fallback_location: member_root_path)
    end
  end

  def update_season(season_and_posts_hash)
    season_and_posts_hash.each do |season, posts_ids|
      SeasonPost.where(season_id: season.to_i).destroy_all

      posts_for_save = posts_ids.split(',')
      (0..posts_for_save.length).each do |i|
        SeasonPost.create(season_id: season.to_i, post_id: posts_for_save[i].to_i, order: i + 1)
      end
    end
  end
end
