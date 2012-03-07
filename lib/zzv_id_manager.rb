class ZzvIdManager
  SALT = 'HC'

  def self.generate_zzv_id_for_email(email)
    CGI.escape(email.crypt(SALT))
  end
end