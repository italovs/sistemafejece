module SiteHelper

	def my_channel_routes
		if member_signed_in?
			validated_my_channel_path
		else
			admin_my_channel_path
		end
	end

	def my_library_routes
		if member_signed_in?
			validated_my_library_path
		else
			admin_my_library_path
		end
	end

	def valid_member_or_admin?
		if admin_signed_in?
			true
		elsif current_member.validated?
			true
		end
	end
end
