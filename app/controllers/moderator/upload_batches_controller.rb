class Moderator::UploadBatchesController < Moderator::BaseController

  def index
    sql = "SELECT DISTINCT DATE_FORMAT( DATE_SUB( created_at, INTERVAL 8 HOUR), '%Y-%m-%d') as date, review_status, COUNT(*) as count FROM upload_batches WHERE state='finished' GROUP BY date, review_status ORDER BY created_at DESC"
    data = UploadBatch.connection.select_all(sql)
    @upload_batches_days = {}
    data.each do |data_row|
      @upload_batches_days[data_row['date']] ||= {}
      @upload_batches_days[data_row['date']][data_row['review_status'] || 'unreviewed'] = data_row['count']
    end
  end

  def show
    date = DateTime.parse(params[:date])
    @upload_batches = UploadBatch.where(:created_at => (date.beginning_of_day..date.end_of_day), :state => 'finished').order('created_at DESC').paginate(:page => params[:page], :per_page => 80)
  end

  def update
    @batch = UploadBatch.find(params[:id])
    @batch.update_attribute :review_status, params[:status]
    render :json => @batch
  end


end
