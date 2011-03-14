class EmailTemplate < ActiveRecord::Base
  attr_accessible :name, :mc_campaign_id, :from_name, :from_address, :subject

  validates_presence_of :name, :mc_campaign_id
  validates_each :mc_campaign_id do |record, attr, value|
     unless record.is_campaign_valid?
       record.errors.add attr, 'MailChimp Campaign ID is not valid'
     end
   end

  before_create :reload_mc_content_no_save
 

  # Gets the MC campaign by id, retrieves the content from MC
  # unescapes the html and stores it in the DB
  # stores the text in the DB. reload_no save does not save the record
  # reload does
  def reload_mc_content
    reload_mc_content_no_save
    save!
  end

  def is_campaign_valid?
    begin
      mc = Hominid::API.new(MAILCHIMP_API_KEYS[:api_key])
      campaigns = mc.find_campaign_by_id( self.mc_campaign_id )
      @campaign = campaigns[0]
    rescue Hominid::APIError
      return nil
    end
    @campaign
  end

 def reload_mc_content_no_save
    #Get the template info from MC
    mc = Hominid::API.new(MAILCHIMP_API_KEYS[:api_key])
    campaigns = mc.find_campaign_by_id( self.mc_campaign_id )
    campaign = campaigns[0]
    content = mc.campaign_content( campaign['id'] , false )

    # Set instance values from template
    self.from_name = campaign['from_name']
    self.from_address = campaign['from_email']
    self.subject = campaign['subject']
    self.text_content = content['text']

    # unescape and interpolate album _ picons and other special elements
    html = CGI::unescapeHTML( content['html'] )
    html = EmailTemplate.interpolate_album_picons( html )
    self.html_content = html
  end

  def formatted_from_address
     "\"#{self.from_name}\" <#{self.from_address}>"
  end

  def self.interpolate_album_picons( html )
    # Group 0 is the whole image tag
    # group 1 is the image url
    # group 2 is the value in the alt tag in between <%=%>
    # group 3 is the whole style argument including the style=""
    regex = /(<img.*src="(.*)".*alt="<%=(.*)%>".*(style=".*;").*>)/
    @html = html

    @html.scan( regex ) do |match|
       if match[2]=='@album.name'
          # This is a match, replace it
          img = []
          img << '<img'
          img << "src=\"<%=@album.cover.thumb_url%>\""
          img << 'alt="<%=@album.name%>"'
          img << match[3]  #the style argument
          #img << "height=\"@album.cover.height\""
          #img << "width=\"@album.cover.width\""
          img << '>'
          img = img.flatten.compact.join(" ").strip.squeeze(" ")
          @html = @html.gsub( match[0], img )
        end
    end
    @html
  end
end
