module CheckoutHelper

  def checkout_progress
    if Gateway.current and Gateway.current.payment_profiles_supported?
      states = %w(ship_address payment   confirm complete)
    else
      states = %w(ship_address  payment  complete)
    end
    order_state = (@order.state == "bill_address" ? 'payment': @order.state )
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

end
