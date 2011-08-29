module CheckoutHelper

  #The checkout breadcrumb
  def checkout_progress
    if Gateway.current and Gateway.current.payment_profiles_supported?
      states = %w(signin ship_address payment confirm complete)
    else
      states = %w(signin ship_address payment complete)
    end
    order_state = @order.state
    items = states.map do |state|
      text = t("order_state.#{state}").titleize

      css_classes = []
      current_index = states.index(order_state)
      state_index = states.index(state)

      if state_index < current_index
        css_classes << 'completed'
        text = link_to text, checkout_state_path(state)
      end

      css_classes << 'next' if state_index == current_index + 1
      css_classes << 'current' if state == order_state
      css_classes << 'first' if state_index == 0
      css_classes << 'last' if state_index == states.length - 1
      # It'd be nice to have separate classes but combining them with a dash helps out for IE6 which only sees the last class
      content_tag('li', content_tag('span', text), :class => css_classes.join('-'))
    end
    content_tag('ol', raw(items.join("\n")), :class => 'progress-steps', :id => "checkout-step-#{order_state}")
  end

  # Creates the state field for addresses, keeps views cleaner.
  def address_state(form, country)
    country ||= Country.find(Spree::Config[:default_country_id])
    have_states = !country.states.empty?
    state_elements = [
        form.collection_select(:state_id, country.states.order(:name),
                               :id, :name,
                               {:include_blank => true},
                               {:class => have_states ? "required" : "hidden",
                                :disabled => !have_states}) +
            form.text_field(:state_name,
                            :class => !have_states ? "required" : "hidden",
                            :disabled => have_states)
    ].join.gsub('"', "'").gsub("\n", "")

    form.label(:state, t(:state)) + '<span class="req">*</span><br />'.html_safe +
        content_tag(:noscript, form.text_field(:state_name, :class => 'required')) +
        javascript_tag("document.write(\"#{state_elements.html_safe}\");")
  end

  def addressbook_dropdown(form, address_kind, addresses )
      return if addresses.nil? or addresses.length <= 0
      address_elements = [
          form.collection_select( address_kind+"_id",
                                  addresses,
                                 :id,
                                 :one_line,
                                 {    :selected => '',
                                     :include_blank => 'Select from addressbook or enter new address'},
                                 {:class => "required"})
      ].join.gsub('"', "'")
      address_elements.html_safe
    end

  def clean_guest_checkout_email( order )
    if /^.*\.guest\.shopper@example.net$/.match( order.email )
      order.email = ''
    end
  end


end
