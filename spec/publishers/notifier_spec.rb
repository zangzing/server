require 'spec_helper'
require 'factory_girl'


describe Notifier do
  before(:each) do
    @sender        = Factory.create(:user)
    @recipient     = Factory.create(:user)
    @photo         = Factory.create(:photo)
    @album         = @photo.album
    @upload_batch  = @photo.upload_batch
    @comment       = Factory.create(:photo_comment)
    @message       = %{ This message is automatically generated for test emails, Its mimics a custom message written by a user.
                        It will be included randomly so you may or may not see it. Line break here ==>\n
                        The following symbols are part of the test. It contains backslash n line breaks for testing
                        <This is full & of HTML symbols <which></should> Line Break here ==>\n
                        &Be<> escaped> END OF TEST MESSAGE}
  end

  describe 'templates should render without errors' do
    it 'photos_ready' do
      lambda{ Notifier.photos_ready( @upload_batch.id ) }.should_not raise_error
    end

    it 'password_reset' do
      lambda{ Notifier.password_reset( @recipient.id ) }.should_not raise_error
    end

    it 'album_liked' do
      lambda{ Notifier.album_liked( @sender.id, @album.id, @recipient.id ) }.should_not raise_error
    end

    it 'photo_liked' do
      lambda{ Notifier.photo_liked( @sender.id, @photo.id, @recipient.id ) }.should_not raise_error
    end

    it 'user_liked' do
      lambda{ Notifier.user_liked( @sender.id, @recipient.id ) }.should_not raise_error
    end

    it 'contribution_error' do
      lambda{ Notifier.contribution_error( @recipient.email ) }.should_not raise_error
    end

    it 'album_shared' do
      lambda{ Notifier.album_shared( @sender.id, @recipient.email, @album.id, @message ) }.should_not raise_error
    end

    it 'album_updated' do
      lambda{ Notifier.album_updated( @sender.id,  @recipient.id, @album.id, @upload_batch.id ) }.should_not raise_error
    end

    it 'contributor_added' do
      lambda{ Notifier.contributor_added( @album.id, @recipient.email, @message ) }.should_not raise_error
    end

    it'welcome' do
      lambda{ Notifier.welcome( @recipient.id ) }.should_not raise_error
    end

    it 'photo_shared' do
      lambda{ Notifier.photo_shared( @sender.id, @recipient.email, @photo.id, @message ) }.should_not raise_error
    end

    it 'beta_invite' do
      lambda{ Notifier.beta_invite( @recipient.email ) }.should_not raise_error
    end

    it 'photo_comment' do
      lambda{ Notifier.photo_comment( @sender.id, @recipient.id, @comment.id ) }.should_not raise_error
    end

    it 'order_confirmed' do
       #lambda{ Notifier.order_confirmed( @order.id ) }.should_not raise_error
       pending 'test not implemented'
    end

    it 'order_cancelled' do
       #lambda{ Notifier.order_cancelled( @order.id ) }.should_not raise_error
       pending 'test not implemented'
    end

    it 'order_shipped' do
      #lambda{ Notifier.order_shipped( @order.shipment.id ) }.should_not raise_error
       pending 'test not implemented'
    end

    it 'request_access' do
      lambda{ Notifier.request_access( @sender.id, @album.id, @message ) }.should_not raise_error
    end

    it 'request_contributor' do
      lambda{ Notifier.request_contributor( @sender.id, @album.id, @message ) }.should_not raise_error
    end
  end
end