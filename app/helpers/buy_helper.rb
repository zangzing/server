module BuyHelper
  def clear_buy_mode_cookie
    cookies['zz.buy.buy_mode_active'] = {:value => 'false', :path => '/'}
  end
end