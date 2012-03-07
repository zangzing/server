class ZzvIdManager
  SALT = 'HC'

  def self.generate_zzv_id_for_email(email)
    CGI.encode(email.crypt(SALT))
  end
end