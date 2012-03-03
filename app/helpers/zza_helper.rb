module ZzaHelper

  # sets a cookie that is used to track unique users in zza and mixpanel.
  # this cookie is also set and read in zza.js
  def set_zzv_id_cookie
    if current_user
      cookies.permanent["_zzv_id"] = current_user.zzv_id
    end
  end

  # reads a cookie that is used to track unique users in zza and mixpanel.
  # this cookie is also set and read in zza.js
  def get_zzv_id_cookie
     cookies["_zzv_id"]
  end
end
