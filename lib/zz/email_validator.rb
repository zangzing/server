module ZZ
  class EmailValidator

    # returns true if valid
    def self.validate(email)
      valid = true
      begin
        validate_email(email)
      rescue Exception => ex
        valid = false
      end
      valid
    end

    # validate a single email, returns an Address object
    def self.validate_email(email)
      begin
        e = Mail::Address.new( email.to_slug.to_ascii.to_s  )
      rescue Mail::Field::ParseError => ex
        # simplify the error message
        raise Mail::Field::ParseError.new("Invalid email format")
      end
      # An address like 'foobar' is a valid local address with no domain so avoid it
      raise Mail::Field::ParseError.new("Invalid email format") if e.domain.nil?
      e
    end

    # parses and cleans list of email addresses.
    # returns emails and any errors, and the addresses
    def self.validate_email_list(email_list)
      email_list = [] if email_list.nil?

      if email_list.kind_of?(Array)
        tokens = email_list
      else
        #split the comma seprated list into array removing any spaces before or after commma
        tokens = email_list.split(/\s*,\s*/)
      end

      # Loop through the tokens and add the bad ones to the errors array
      token_index = 0
      emails = []
      errors = []
      addresses = []
      tokens.each do |t|
        begin
          #TODO: Email validator in share.rb does not handle formatted_emails just the address
          address = validate_email(t)
          addresses << address
          emails << address.address
        rescue Mail::Field::ParseError => ex
          errors << ZZAPIInvalidListError.build_missing_item(token_index, t, ex.message)
        end
        token_index+= 1
      end
      return emails, errors, addresses
    end


  end
end
