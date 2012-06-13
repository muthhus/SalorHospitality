class BookingsController < ApplicationController

  def show
    if params[:id] != 'last'
      @booking = @current_vendor.bookings.existing.find_by_id(params[:id])
    else
      @booking = @current_vendor.bookings.existing.find_all_by_finished(true).last
    end
    redirect_to '/' and return if not @booking
    @previous_booking, @next_booking = neighbour_models('bookings', @booking)
    respond_to do |wants|
      wants.html
      wants.bill { render :text => generate_escpos_invoice(@booking) }
    end
  end

  def by_nr
    @booking = @current_vendor.bookings.existing.find_by_nr(params[:nr])
    if @booking
      redirect_to booking_path(@booking)
    else
      redirect_to booking_path(@current_vendor.bookings.existing.last)
    end
  end

end