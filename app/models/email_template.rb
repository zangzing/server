class EmailTemplate < ActiveRecord::Base
  BODY_SUBSTITUTION_MACRO = '*|BODY|*'

  attr_accessor :skip_merge

  belongs_to :email
  has_one :production_email, :class_name => "Email",
          :inverse_of => :production_template,
          :foreign_key => 'production_template_id'

  validates :email_id, :presence => true
  validates :name, :presence => true

  before_save do |inner_template|
    inner_template.merge_with_outer! unless inner_template.is_outer? || inner_template.skip_merge
  end

  after_save do |template|
    if template.is_outer?
      EmailTemplate.all.each do |inner_template|
        next if inner_template==template #Don't update the outer template
        inner_template.skip_merge = true
        inner_template.merge_with_outer!
        inner_template.save
      end
    end
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

  def merge_with_outer!
    return nil if is_outer?

    html = self.outer_template.html_body.gsub(BODY_SUBSTITUTION_MACRO, self.html_body || '')
    text = self.outer_template.text_body.gsub(BODY_SUBSTITUTION_MACRO, self.text_body || '')

    html_inliner = Premailer.new(html, :with_html_string => true, :warn_level => Premailer::Warnings::SAFE)

    self.html_content_will_change!
    self.html_content = html_inliner.to_inline_css
    self.text_content_will_change!
    self.text_content = text
    replace_unsub
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

  def replace_unsub
    # look for *|UNSUB|* and replace with <%= @unsubscribe_url %>
    regex = /\*\|UNSUB\|\*/
    repl  = '<%=@unsubscribe_url%>'
    self.html_content_will_change!
    self.html_content.gsub!( regex, repl)
    self.text_content_will_change!
    self.text_content.gsub!( regex, repl)
  end

end
