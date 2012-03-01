module ControllerSpecHelper
  def login
    @current_user = Factory(:user)
    @any_current_user = @current_user
    controller.stub!(:current_user).and_return(@current_user)
    controller.stub!(:any_current_user).and_return(@any_current_user)
  end

  def logout
    controller.stub!(:current_user).and_return(nil)
    controller.stub!(:any_current_user).and_return(nil)
  end
end