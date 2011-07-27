require 'spec_helper'

describe Comment do
  before(:each) do
    @user = Factory(:user)
    @user.save!
    puts "user: " + @user.id.to_s
  end


  it "should cache comment count in commentable object" do
    commentable = Commentable.find_or_create_by_photo_id(12345)

    comment = commentable.comments.new
    comment.comment = "this is a comment"
    comment.user = @user
    comment.save

    comment = commentable.comments.new
    comment.comment = "this is another comment"
    comment.user = @user
    comment.save

    commentable = Commentable.find(commentable.id)
    commentable.comments.length.should eql(2)
    commentable.comments_count.should eql(2)

  end

  it "should include user information in json" do
    commentable = Commentable.find_or_create_by_photo_id(12345)
    comment = commentable.comments.new
    comment.comment = "this is a comment"
    comment.user = @user
    comment.save

    commentable.comments_as_hash[:comments][0][:user][:profile_photo_url].should_not be_nil
    commentable.comments_as_hash[:comments][0][:user][:first_name].should_not be_nil
    commentable.comments_as_hash[:comments][0][:user][:last_name].should_not be_nil
  end

  it "should return metadata for all photos in album" do
    Album.stub!(:find).and_return(Factory(:album_with_photos))
    hash = Commentable.metadata_for_album_as_hash(12345)
    puts hash.to_s

  end


end