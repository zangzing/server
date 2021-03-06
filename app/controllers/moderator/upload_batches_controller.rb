class Moderator::UploadBatchesController < Moderator::BaseController

  def index
    sql = "SELECT DISTINCT DATE_FORMAT( DATE( created_at), '%Y-%m-%d') as date, review_status, COUNT(*) as count FROM upload_batches WHERE state='finished' GROUP BY date, review_status ORDER BY date DESC"
    data = UploadBatch.connection.select_all(sql)
    @upload_batches_days = []
    current_date = nil
    data.each do |data_row|
      if current_date != data_row['date']
        current_date = data_row['date']
        @upload_batches_days << {'date' => current_date}
      end

      @upload_batches_days.last[data_row['review_status']] = data_row['count']

    end
  end

  def show
    date = DateTime.parse(params[:date])
    where = {
      :created_at => (date.beginning_of_day..date.end_of_day),
      :state => 'finished'
    }
    where[:review_status] = params[:filter] if %w(good bad unreviewed).include?(params[:filter])
    @upload_batches = UploadBatch.where(where).order('created_at DESC').paginate(:page => params[:page], :per_page => 80)
  end

  def update
    @batch = UploadBatch.find(params[:id])
    @batch.update_attribute :review_status, params[:status]
    render :json => @batch
  end

  def clean_empty_batches
    sql = 'select upload_batches.* from upload_batches where upload_batches.state = "finished" and upload_batches.review_status != "good" and not exists (select upload_batch_id from photos where photos.upload_batch_id = upload_batches.id)'
    upload_batches = UploadBatch.find_by_sql(sql)
    upload_batches.each { |batch|
      batch.update_attribute(:review_status, "good")
    }

    redirect_to moderator_upload_batches_path
  end
end
