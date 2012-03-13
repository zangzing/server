module ControllerSpecHelper
  def login
    @current_user = Factory(:user)
    controller.stub!(:current_user).and_return(@current_user)
  end

  def logout
    controller.stub!(:current_user).and_return(nil)
  end
end