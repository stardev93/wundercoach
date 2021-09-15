class Admin::BookingsController < Admin::AdminController
  before_action :set_booking, only: %i(show edit update destroy makecurrent)

  # GET /admin/bookings
  def index
    @bookings = Booking.paid.includes(:account).page(params[:page]).order('bookings.created_at DESC')
    @bookings = @bookings.references(:account).where('accounts.name LIKE ?', "%#{params[:search]}%") if params[:search]
  end

  # GET /admin/bookings/1
  def show; end

  # GET /admin/bookings/new
  def new
    @booking = Admin::Booking.new
  end

  # GET /admin/bookings/1/edit
  def edit; end

  # POST /admin/bookings
  def create
    @booking = Admin::Booking.new(booking_params)

    if @booking.save
      redirect_to @booking, notice: t(:creation_successful)
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /admin/bookings/1
  def update
    if @booking.update(booking_params)
      redirect_to admin_account_path(@booking.account)+'#bookings', notice: t(:update_successful)
    else
      render action: 'edit'
    end
  end

  # DELETE /admin/bookings/1
  def destroy
    @booking_account = @booking.account
    @booking.destroy
    redirect_to admin_account_path(@booking_account)+'#bookings', notice: t(:delete_successful)
  end

  # GET /admin/bookings/1/makecurrent
  def makecurrent
    @booking.account.bookings.each do |oldcurrentbooking|
      oldcurrentbooking.is_current = false
      oldcurrentbooking.save
    end
    @booking.is_current = true
    @booking.save
    redirect_to admin_account_path(@booking.account)+'#bookings', notice: t(:current_booking_updated)
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_booking
    @booking = Booking.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def booking_params
    params.require(:booking).permit(:comments, :valid_until, :paymentplan_id, :type, :trial_expiry_reminder_one_sent, :trial_expiry_reminder_two_sent, :trial_expired_one_sent, :trial_expired_two_sent, :is_current, :valid_from, :predecessor_id)
  end
end
