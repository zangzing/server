module ZZ
  module MailChimp
    class Template
      @@templates

      def initialize( template_name )
        if @@templates.nil? 
          tmp_temps = ZZ::MailChimp.get_templates
            raise Error, "No user templates found"  if tmp_temps.nil? || tmp_temps.length <= 0
          tmp_temps.each do | temp |
            @@templates[temp['title']]=temp
          end
        end
        
        @template = @@templates[template_name]
        raise Error, "No user template named #{template_name} found" if @template.nil?
      end

      def mail_merge( merge_vars )
        l_html = html
        l_text = text
        merge_vars.keys.each do |key|
          l_html.gsub!(/\*\|key\|\*/, merge_vars[key] )
          l_text.gsub!(/\*\|key\|\*/, merge_vars[key] )
        end
        return l_html, l_text
      end

      private
      def html
        load_body if @template['html'].nil?
        @template['html']
      end

      def text
        load_body if @template['text'].nil?
        @template['text']
      end

      def load_body
        # Get the template's source and preview (preview is the html we want to user)
        tmp_info = ZZ::MailChimp::Chimp.template_info( @template['id'].to_i, 'user' )
        raise Error, "No body found for template: #{@template['title']}" if tmp_info.nil?
        # Inline all of the css in the html get it ready to send
        tmp_html = ZZ::MailChimp::Chimp.inline_css( tmp_info['preview'], true)
        raise Error, "Unable to inline CSS for html template:  #{@template['title']}" if tmp_html.nil?
        # Generate a text version from the html
        tmp_text = ZZ::MailChimp::Chimp.generateText( 'html', tmp_html )
        raise Error, "Unable to get text for template:  #{@template['title']}" if tmp_text.nil?
        @template['html'] = tmp_html
        @template['text'] = tmp_text
      end
    end
  end
end