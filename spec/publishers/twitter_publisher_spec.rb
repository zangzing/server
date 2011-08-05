require 'spec_helper'
require 'factory_girl'


describe TwitterPublisher do
  it 'should truncate message to fit message and url' do
      message = 200.times.map { "x" }.join
      url = "http://www.zangzing.com"

      TwitterPublisher.should_receive(:post_message_to_twitter).with do |*args|
        args[1].length == 140
      end

      TwitterPublisher.post_link_to_twitter(Factory.create(:user), message, url)

  end


  it 'should post comment to twitter' do
#    photo = Factory.create(:photo, :album => Factory.create(:album), :user => Factory.create(:user))
#    commentable = Commentable.find_or_create_by_photo_id(photo.id)
#    comment = Factory.create(:comment, :commentable=>commentable, :user => Factory.create(:user))
    comment = Factory.create(:photo_comment)


    TwitterPublisher.should_receive(:post_message_to_twitter)

    TwitterPublisher.photo_comment(comment.id)

  end


  it 'should post comment to facebook' do

  end

end
