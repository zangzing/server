require 'spec_helper'
require 'factory_girl'


describe FacebookPublisher do
  it 'should post comment to facebook' do
    photo = Factory.create(:photo, :album => Factory.create(:album), :user => Factory.create(:user))
    commentable = Commentable.find_or_create_by_photo_id(photo.id)
    comment = Factory.create(:comment, :commentable=>commentable, :user => Factory.create(:user))

    FacebookPublisher.should_receive(:post_to_facebook)

    FacebookPublisher.photo_comment(comment.id)
    
  end


end
