class FacebookPostsController < FacebookController


  def index
    @name = facebook_graph.get('me/feed')
    render :text => @name.inspect
  end


   def create
     #graph = HyperGraph.new(get_facebook_token)
     facebook_graph.post("#{params[:object_id]}/feed", :message => params[:message])
   end
end





#puts HyperGraph.authorize_url('f4d63fedf5efb80582e053cde0929378', 'http://localhost:3000/facebook_connect/receive_token', :scope => 'publish_stream', :display => 'popup')

#puts HyperGraph.get_access_token('f4d63fedf5efb80582e053cde0929378', 'd551ae9821d42fbb22de534f70502b0b', 'http://localhost:3000/facebook/', '2.RsC__FvAuaVrnbpzPgsW9w__.3600.1275674400-100001174482639|dTpzwleRk4ISwTNRWVAm9Np82aI.')

#graph = HyperGraph.new('112996675412403|2.RsC__FvAuaVrnbpzPgsW9w__.3600.1275674400-100001174482639|32h60osDTWaMTwZfQmfQRfDlCVc.&expires')

#puts graph.get('me').inspect
