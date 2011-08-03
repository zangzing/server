require 'spec_helper'
require 'factory_girl'


describe TwitterPublisher do
  it 'should post comment to twitter' do
    photo = Factory.create(:photo, :album => Factory.create(:album), :user => Factory.create(:user))
    commentable = Commentable.find_or_create_by_photo_id(photo.id)
    comment = Factory.create(:comment, :commentable=>commentable, :user => Factory.create(:user))

    TwitterPublisher.should_receive(:post_to_twitter)

    TwitterPublisher.photo_comment(comment.id)

  end


end
