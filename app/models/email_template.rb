class EmailTemplate < ActiveRecord::Base
  BODY_SUBSTITUTION_MACRO = '*|BODY|*'

  attr_accessible :name, :email_id, :mc_campaign_id, :from_name, :from_address, :subject, :reply_to, :category, :html_body, :text_body
  attr_accessor :skip_merge

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

  before_save do |inner_template|
    unless inner_template.is_outer? || inner_template.skip_merge
      inner_template.html_content = inner_template.outer_template.html_body.gsub(BODY_SUBSTITUTION_MACRO, inner_template.html_body || '')
      inner_template.text_content = inner_template.outer_template.text_body.gsub(BODY_SUBSTITUTION_MACRO, inner_template.text_body || '')
    end
  end

  after_save do |template|
    if template.is_outer?
      EmailTemplate.all.each do |inner_template|
        next if inner_template==template #Don't update the outer template
        inner_template.skip_merge = true
        inner_template.html_content = template.html_body.gsub(BODY_SUBSTITUTION_MACRO, inner_template.html_body || '')
        inner_template.text_content = template.text_body.gsub(BODY_SUBSTITUTION_MACRO, inner_template.text_body || '')
        inner_template.save
      end
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

  def outer_template
    @outer_template ||= self.class.outer
  end

  def self.outer
    Email.outer_template.first.production_template
  end

  def is_outer?
    self.outer_template == self
  end




  def is_campaign_valid?
    return true if Rails.env.development?
    @campaign = nil
    campaigns =gb.campaigns(:filters => { :folder_id => 21177, :campaign_id => self.mc_campaign_id })['data']
    @campaign = campaigns[0] if campaigns
    @campaign
  end

 def reload_mc_content_no_save
   return true if Rails.env.development?
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
    replace_unsub
    replace_at_media
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


  def sendgrid_category
    {'category' => self.category }
  end

  def unescape_links
    # look for hrefs in links that were <%($1)%> before but were urlencoded
    # Group 1 is whatever was in between the href"<% %>"
    self.html_content_will_change!
    self.html_content.gsub!( /href="(mailto:)*%3C%([^"]*)%%3E"/){ "href=\"#{$1}<%#{CGI::unescape($2)}%>\"" }
  end

  def remove_double_http
    # look for http://http:// and replace with http://  (a common MC problem)
    self.html_content_will_change!
    self.html_content.gsub!(/href="http:\/\/<%=/, 'href="<%=')
  end

  def replace_unsub
    # look for *|UNSUB|* and replace with <%= @unsubscribe_url %>
    regex = /\*\|UNSUB\|\*/
    repl  = '<%=@unsubscribe_url%>'
    self.html_content_will_change!
    self.html_content.gsub!( regex, repl)
    self.text_content_will_change!
    self.text_content.gsub!( regex, repl)
  end

  # MC does not like @media css tags. We use a trick to pass them from the template to us
  # 1.- insert an #at_media_block{} css tag
  # 2.- remove the @media from the begining of your tag and enclose it in double quotes
  # 3.- replace curly braces with square braces and semi colons with bars
  # 4.- MC will let that combination through
  # We fix it here.
  def replace_at_media
    # look for </style> and replace with <%= @unsubscribe_url %>
    regex = /#at_media_block\{[\s.]*"([^{]*)";[\s.]*\}/
    matches = regex.match( self.html_content )
    if matches
      tag_content = matches[1]
      tag_content.gsub!(/\[/,'{') # replace square braces with curly ones
      tag_content.gsub!(/\]/,'}')
      tag_content.gsub!(/\|/,';') # replace bar with semi-colon
      tag_content.insert(0, '@media ') # insert @media tag at front  Tag content is now ready.
      self.html_content_will_change!
      self.html_content.gsub!( regex, tag_content)
    end
  end

  def self.interpolate_images( html )
    # Group 0 is the whole image tag
    # group 1 is the image url
    # group 2 is the value in the alt tag in between <%=%>
    # group 3 is the whole style argument including the style=""
    regex = /(<img.*alt="<%=(.*)%>".*(style=".*;")[^<]*>)/
    @html = html

    @html.scan( regex ) do |match|
      case match[1]
        when '@album.name'
          # This is an album picon, replace it
          img = []
          img << '<img'
          img << "src=\"<%=(@album.cover ? @album.cover.thumb_url : '')%>\""
          img << 'alt="<%=@album.name%>"'
          img << match[2]
          img << '>'
          img = img.flatten.compact.join(" ").strip.squeeze(" ")
          @html = @html.gsub( match[0], img )
        when  '@photo.caption'
          # This is a photo, replace it
          img = []
          img << '<img'
          img << "src=\"<%=@photo.thumb_url%>\""
          img << 'alt="<%=@photo.caption%>"'
          img << match[2]  
          img << '>'
          img = img.flatten.compact.join(" ").strip.squeeze(" ")
          @html = @html.gsub( match[0], img )
        when  '@photos'
          # This is the result of an uploadbatch operation, take @photos[0]
          img = []
          img << '<img'
          img << "src=\"<%=@photos[0].thumb_url%>\""
          img << 'alt="<%=@photos[0].caption%>"'
          img << match[2]
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
