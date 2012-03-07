module ZzaHelper

  # sets a cookie that is used to track unique users in zza and mixpanel.
  # this cookie is also set and read in zza.js
  def set_zzv_id_cookie
    if current_user
      cookies.permanent["_zzv_id"] = {
          :value => current_user.zzv_id,
          :domain => "zangzing.com",
      }
    end
  end

  # reads a cookie that is used to track unique users in zza and mixpanel.
  # this cookie is also set and read in zza.js
  def get_zzv_id_cookie
     cookies["_zzv_id"]
  end

  def delete_zzv_id_cookie
     cookies.delete ("_zzv_id", :domain => "zangzing.com")
  end

  # this handles existing user sessions
  # we want to upgrade them to use correct zzv_id
  def check_zzv_id_cookie
    set_zzv_id_cookie
  end
end
