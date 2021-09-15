# Update EventDesign of your account
class Account::EventDesignController < ApplicationController
  authorize_resource :account, parent: false
  layout 'account'

  # GET /event_design
  def show; end

  # GET /event_design/edit
  def edit; end

  # PATCH/PUT /event_design
  def update
    if @account.update(event_design_params)
      redirect_to event_design_url, notice: t(:update_successful)
    else
      render action: 'edit'
    end
  end

  private

  # nilifies blank inputs, which enables deleting images like favicon by
  # passing an empty favicon param
  def event_design_params
    params
      .require(:account)
      .permit(
        :order_bcc_list, :show_header_image, :terms_link_text, :terms_required,
        :terms_link, :gdpr_required, :gdpr_link, :gdpr_link_text, :revocation_required, :revocation_link, :revocation_link_text,
        :event_contact, :css_code, :js_code, :favicon,
        :checkout_title, :checkout_footer, :show_signup_search, :index_path
      )
      .map {|key, value| [key, value.empty? ? nil : value] }
      .to_h
  end
end
