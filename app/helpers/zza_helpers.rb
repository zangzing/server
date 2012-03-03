module PrettyUrlHelper

  # sets a cookie that is used to track unique users in zza and mixpanel.
  # this cookie is also set and read in zza.js
  def set_zzv_id_cookie
    if current_user
      cookies["_zzv_id"] = { :value => current_user.zzv_id, :expires => 10.years.from_now }
    end
  end

  # reads a cookie that is used to track unique users in zza and mixpanel.
  # this cookie is also set and read in zza.js
  def get_zzv_id_cookie
     cookies["_zzv_id"]
  end
end
