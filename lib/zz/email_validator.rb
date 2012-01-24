module ZZ
  class EmailValidator


    EmailAddress = begin
      qtext = '[^\\x0d\\x22\\x5c\\x80-\\xff]'
      dtext = '[^\\x0d\\x5b-\\x5d\\x80-\\xff]'
      atom = '[^\\x00-\\x20\\x22\\x28\\x29\\x2c\\x2e\\x3a-' +
          '\\x3c\\x3e\\x40\\x5b-\\x5d\\x7f-\\xff]+'
      quoted_pair = '\\x5c[\\x00-\\x7f]'
      domain_literal = "\\x5b(?:#{dtext}|#{quoted_pair})*\\x5d"
      quoted_string = "\\x22(?:#{qtext}|#{quoted_pair})*\\x22"
      domain_ref = atom
      sub_domain = "(?:#{domain_ref}|#{domain_literal})"
      word = "(?:#{atom}|#{quoted_string})"
      domain = "#{sub_domain}(?:\\x2e#{sub_domain})*"
      local_part = "#{word}(?:\\x2e#{word})*"
      addr_spec = "#{local_part}\\x40#{domain}"
      pattern = /\A#{addr_spec}\z/
    end


    def self.validate(email)
      email =~ EmailAddress
    end

    # validate a single email
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
    # returns emails and any errors
    def self.validate_email_list(email_list)

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
      tokens.each do |t|
        begin
          #TODO: Email validator in share.rb does not handle formatted_emails just the address
          emails << validate_email(t).address.to_s
        rescue Mail::Field::ParseError => ex
          errors << { :index => token_index, :token => t, :error => ex.message }
        end
        token_index+= 1
      end
      return emails, errors
    end


  end
end
