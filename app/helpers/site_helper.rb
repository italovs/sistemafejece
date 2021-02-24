module SiteHelper

	def video_channel_routes
		if member_signed_in?
			validated_tv_channel_path
		else
			admin_tv_channel_path
		end
	end

	def valid_member_or_admin?
		if admin_signed_in?
			true
		else
			current_member.valid?
		end
	end
end
