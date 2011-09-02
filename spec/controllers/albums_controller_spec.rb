require 'spec_helper'

describe AlbumsController do
  include ControllerSpecHelper


  def get_action_and_cache_version(path)
      route = Rails.application.routes.recognize_path(path)
      action = route[:action]
      cache_version = path.match(/\?ver=(.*)/)[1]
      return action, cache_version
  end

  context 'when i view my homepage' do
    before(:each) do
      login
      @me = @current_user
      @person_i_follow = Factory.create(:user)
      Like.add(@me.id, @person_i_follow.id, Like::USER)
    end

    describe 'My Albums section' do
      it 'should show all my public albums' do
        pending 'test not implemented'
      end

      it 'should show all my hidden albums' do
        pending 'test not implemented'
      end

      it 'should show all my password albums' do
        pending 'test not implemented'
      end

      it 'should show changed album names' do
        pending 'test not implemented'
      end

      it 'should not show deleted albums' do
        pending 'test not implemented'
      end

      it 'should show new albums' do
        pending 'test not implemented'
      end



    end

    describe 'Albums I Like section' do

      def should_show_all_liked_albums_with_privacy(privacy)
        album_i_like = Factory.create(:album, :privacy=>privacy, :completed_batch_count=>1)
        Like.add(@me.id, album_i_like.id, Like::ALBUM)

        # get the homepage 'html'
        get :index, {:user_id => @me.id}

        # make the json call based on the @liked_albums_path variable
        action, cache_version = get_action_and_cache_version(assigns[:liked_albums_path])
        xhr :get, action, {:user_id => @me.id, :ver=>cache_version}


        albums = JSON.parse(response.body)
        albums.count.should == 1
        albums[0]['id'].should == album_i_like.id
      end


      it 'should show all the public albums i like' do
        should_show_all_liked_albums_with_privacy(Album::PUBLIC)
      end

      it 'should show all the hidden albums i like' do
        should_show_all_liked_albums_with_privacy(Album::HIDDEN)
      end

      it 'should show all the password albums i like' do
        should_show_all_liked_albums_with_privacy(Album::PASSWORD)
      end

      it 'should show all the public albums of people i follow' do
        pending 'test not implemented'
      end

      it 'should not show the hidden albums of people i follow' do
        pending 'test not implemented'
      end

      it 'should not show the password albums of people i follow' do
        pending 'test not implemented'
      end

      it 'should not show albums or people i follow where the album was changed from public to password' do
        pending 'test not implemented'
      end
    end

  end

  context 'when i view someone else\'s homepage' do
    before(:each) do
      login
      @user = Factory.create(:user)
      @followed_by_user = Factory.create(:user)
      Like.add(@user.id, @followed_by_user.id, Like::USER)
    end

    describe 'His Albums section' do
      it 'should show all his public albums' do
        pending 'test not implemented'
      end

      it 'should not show any of his hidden albums' do
        pending 'test not implemented'
      end

      it 'should not show any of his password albums' do
        pending 'test not implemented'
      end

    end

    describe 'Album He Likes section' do
      it 'should show all the public albums that he likes' do
        pending 'test not implemented'
      end

      it 'should not show any of the hidden albums that he likes' do
        pending 'test not implemented'
      end

      it 'should not show any of the password albums that he likes' do
        pending 'test not implemented'
      end

      it 'should show all the public albums of people he follows' do
        pending 'test not implemented'
      end

      it 'should not show any of the hidden albums of people he follows' do
        pending 'test not implemented'
      end

      it 'should not show any of the password albums of people he follows' do
        pending 'test not implemented'
      end

    end

  end

  


end

