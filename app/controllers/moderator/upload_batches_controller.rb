class Moderator::UploadBatchesController < Moderator::BaseController

  def index
    sql = "   SELECT DISTINCT DATE_FORMAT( DATE_SUB( created_at, INTERVAL 8 HOUR), '%Y-%m-%d') as date FROM upload_batches WHERE state = 'finished' ORDER BY created_at DESC"
    @upload_batches_days = UploadBatch.connection.select_values(sql)
  end

  def show
    date = DateTime.parse(params[:date])
    @upload_batches = UploadBatch.where(:created_at => (date.beginning_of_day..date.end_of_day), :state => 'finished').order('created_at DESC').paginate(:page => params[:page], :per_page => 80)
  end


end
