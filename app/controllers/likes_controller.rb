class LikesController < ApplicationController
  before_filter :require_user, :only => :toggle

  def index
    wanted_subjects = params['wanted_subjects']
    render :nothing => true, :status =>400 and return if wanted_subjects.nil?

    subjects =  Hash.new()
    wanted_subjects.keys.each do |wanted_id|
      type = case wanted_subjects[wanted_id].downcase
               when 'photo' then  Like::PHOTO
               when 'album' then Like::ALBUM
               when 'user'  then Like::USER
             end
      subjects[wanted_id] = { :count => 0, :user => false, :type => type }
    end

    LikeCounter.find_all_by_subject_id( wanted_subjects.keys ).each do |counter|
      subjects[ counter.subject_id ][:count]= counter.counter
    end

    if current_user
      Like.find_all_by_user_id_and_subject_id( current_user.id, wanted_subjects.keys).each  do | like |
        subjects[ like.subject_id ][:user]=true
      end
    end
    render :json =>subjects
  end

  def toggle

    if current_user
      current_user_id = current_user.id
    else
      current_user_id = nil
    end
    
    if params['user_id']
      #Like.toggle( current_user_id, params['user_id'], Like::USER )
      ZZ::Async::LikeClick.enqueue( current_user_id, params['user_id'], Like::USER )
      render :nothing => true and return
    elsif params['album_id']
      #Like.toggle( current_user_id, params['album_id'], Like::ALBUM )
      ZZ::Async::LikeClick.enqueue( current_user_id, params['album_id'], Like::ALBUM )
      render :nothing => true and return
    elsif params['photo_id']
      #Like.toggle( current_user_id, params['photo_id'], Like::PHOTO )
      ZZ::Async::LikeClick.enqueue( current_user_id, params['photo_id'], Like::PHOTO )
      render :nothing => true and return
    end

    render :nothing => true, status=> 400 and return
  end
  
end