Admin::ShipmentsController.class_eval do
  def update
    assign_line_items
    if @shipment.update_attributes params[:shipment]
      @order.save

      flash[:notice] = flash_message_for(@shipment, :successfully_updated)
      return_path = @order.completed? ? edit_admin_order_shipment_path(@order, @shipment) : admin_order_adjustments_path(@order)
      respond_with(@object) do |format|
        format.html { redirect_to return_path }
      end
    else
      respond_with(@shipment) { |format| format.html { render :action => 'edit' } }
    end
  end

  def assign_line_items
    return unless params.has_key? :line_items
    @shipment.line_item_ids = params[:line_items].keys
  end
end