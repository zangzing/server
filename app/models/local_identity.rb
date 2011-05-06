class LocalIdentity < Identity

  def contacts_refreshed
    # credentials are not needed for local identities but we must set
    # the string to comply with the identity behavior:
    # A new identity has no credentials, a valid identity has credentials
    self.credentials = "confidential-local-credentials"
    self.last_contact_refresh = Time.now()
  end

  def credentials
    "confidential-local-credentials"
  end

end