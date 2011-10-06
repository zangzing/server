module CheckoutHelper

  #The checkout breadcrumb
  def checkout_progress

    states = %w(ship_address payment confirm)
    order_state = @order.state
    items = states.map do |state|
      text = t("order_state.#{state}").titleize

      css_classes = []
      current_index = states.index(order_state)
      state_index = states.index(state)

      if state_index < current_index
        css_classes << 'completed'
        #text = link_to text, checkout_state_path(state)
      end
      css_classes << 'next' if state_index == current_index + 1
      css_classes << 'current' if state == order_state
      css_classes << 'first' if state_index == 0
      css_classes << 'last' if state_index == states.length - 1
      # It'd be nice to have separate classes but combining them with a dash helps out for IE6 which only sees the last class

      cell_options ={ :class => css_classes.join(' ') }
      if state_index < current_index
        case state
        when 'cart':
          cell_options[:onclick] = "document.location.href='#{cart_path(state)}';"
        when 'signin'
          cell_options[:onclick] = ''
        else
          cell_options[:onclick] = "document.location.href='#{checkout_state_path(state)}';"
        end
      end
      content_tag('td',
                  content_tag('div',
                      content_tag('div', state_index+1,:class => 'state_index' )+
                      content_tag('div', text, :class => 'state_name'),
                  :class=>'state'),
                  cell_options)
    end
    row = content_tag('tr', raw(items.join("\n")), :class => 'progress-steps', :id => "checkout-step-#{order_state}")
    content_tag( 'table', row, :class => 'progress-bar' )
  end

  # Creates the state field for addresses, keeps views cleaner.
  def states_dropdown(form, country)
    country ||= Country.find(Spree::Config[:default_country_id])
    state_elements = [
        form.collection_select(:state_id, country.states.order(:name),
                               :id, :name,
                               {:include_blank => t('select_state')},
                               {:class => "required",
                                'data-original-title'=>t(:state)})
    ].join.gsub('"', "'").gsub("\n", "")
    javascript_tag("document.write(\"#{state_elements.html_safe}\");")
  end

  def addressbook_dropdown(form, address_kind, order )
      addresses = order.user.addresses
      return if addresses.nil? or addresses.length <= 0
      address_elements = [
          form.collection_select( address_kind+"_id",
                                  addresses,
                                 :id,
                                 :one_line,
                                 { :include_blank => 'Select from Address Book or enter new address'},
                                 { :id => 'addressbook_dropdown'})
      ].join.gsub('"', "'")
      address_elements.html_safe
    end

  def creditcard_logo(creditcard)
    type = creditcard.cc_type

    if  %w( discover master visa american_express).include? type
      src = "/images/store/#{type}_logo.png"
      image_tag src, { :class => "cclogo" }
    else
      ''
    end
  end

end
