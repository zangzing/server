require 'spec_helper'
require 'factory_girl'


describe TwitterPublisher do
  it 'should truncate message to fit message and url' do
      message = 200.times.map { "x" }.join
      url = "http://www.zangzing.com"

      TwitterPublisher.should_receive(:post_message_to_twitter).with do |*args|
        args[1].length == 140 && args[1].include?("...")
      end

      TwitterPublisher.post_link_to_twitter(Factory.create(:user), message, url)

  end


  it 'should post comment to twitter' do
    comment = Factory.create(:photo_comment)

    TwitterPublisher.should_receive(:post_message_to_twitter)

    TwitterPublisher.photo_comment(comment.id)

  end


  it 'should post comment to facebook' do

  end

end
