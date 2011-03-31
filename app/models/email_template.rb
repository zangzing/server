class EmailTemplate < ActiveRecord::Base
  attr_accessible :name, :email_id, :mc_campaign_id, :from_name, :from_address, :subject, :reply_to, :category


  belongs_to :email
  has_one :production_email, :class_name => "Email",
          :inverse_of => :production_template,
          :foreign_key => 'production_template_id'

  validates_presence_of :mc_campaign_id, :email_id
  validates_each :mc_campaign_id, :on => :create do |record, attr, value|
     unless record.is_campaign_valid?
       record.errors.add attr, 'MailChimp Campaign ID is not valid'
     end
   end

  before_save :reload_mc_content_no_save
 

  # Gets the MC campaign by id, retrieves the content from MC
  # unescapes the html and stores it in the DB
  # stores the text in the DB. reload_no save does not save the record
  # reload does
  def reload_mc_content
    #reload_mc_content_no_save
    save
  end


  def is_campaign_valid?
    @campaign = nil
    campaigns =gb.campaigns(:filters => { :folder_id => 21177, :campaign_id => self.mc_campaign_id })['data']
    @campaign = campaigns[0] if campaigns
    @campaign
  end

 def reload_mc_content_no_save
    #Get the template info from MC
    campaign = is_campaign_valid?
    content =  gb.campaign_content(  {'cid' => campaign['id'] , 'for_archive' => false} )

    # Set instance values from template
    self.name = campaign['title']
    self.from_name = campaign['from_name']
    self.from_address = campaign['from_email']
    self.subject = campaign['subject']
    self.text_content = content['text']

    # unescape and interpolate images and other special elements
    self.html_content = EmailTemplate.interpolate_images(  CGI::unescapeHTML( content['html'] )  )
    remove_double_http
    unescape_links

    true
  end

  def formatted_from
     "#{self.from_name}<#{self.from_address}>"
  end

  def formatted_reply_to
      if  self.reply_to && self.reply_to.length > 0
        self.reply_to
      else
        self.from_address
      end
  end


  def sendgrid_category_header
    {'X-SMTPAPI' => {'category' => self.category }.to_json }
  end

  def unescape_links
    # look for hrefs in links that were <%($1)%> before but were urlencoded
    # Group 1 is whatever was in between the href"<% %>"
    self.html_content.gsub!( /href="(mailto:)*%3C%([^"]*)%%3E"/){ "href=\"#{$1}<%#{CGI::unescape($2)}%>\"" }
  end

  def remove_double_http
    # look for http://http:// and replace with http://  (a common MC problem)
    self.html_content.gsub!(/href="http:\/\/<%=/, 'href="<%=')
  end

  def self.interpolate_images( html )
    # Group 0 is the whole image tag
    # group 1 is the image url
    # group 2 is the value in the alt tag in between <%=%>
    # group 3 is the whole style argument including the style=""
    regex = /(<img.*src="(.*)".*alt="<%=(.*)%>".*(style=".*;").*>)/
    @html = html

    @html.scan( regex ) do |match|
      case match[2]
        when '@album.name'
          # This is an album picon, replace it
          img = []
          img << '<img'
          img << "src=\"<%=(@album.cover ? @album.cover.thumb_url : '')%>\""
          img << 'alt="<%=@album.name%>"'
          img << match[3]  #the style argument
          #img << "height=\"@album.cover.height\""
          #img << "width=\"@album.cover.width\""
          img << '>'
          img = img.flatten.compact.join(" ").strip.squeeze(" ")
          @html = @html.gsub( match[0], img )
        when  '@photo.caption'
          # This is a photo, replace it
          img = []
          img << '<img'
          img << "src=\"<%=@photo.thumb_url%>\""
          img << 'alt="<%=@photo.caption%>"'
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

  private

  def gb
    @gb ||= Gibbon::API.new(MAILCHIMP_API_KEYS[:api_key])
  end

end
