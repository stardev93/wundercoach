class Adpartner < ActiveRecord::Base
  # Find and render a widget via jsonp
  class WidgetsController < ApplicationController
    skip_before_action :set_locale
    skip_before_action :require_login
    skip_before_action :set_tenant_and_account
    skip_before_action :verify_authenticity_token

    def show
      respond_to do |format|
        format.js do
          # TODO: Error handling/RecordNotFound
          widget = Widget.find_by_token(params[:widget_token])
          event_list = ::Embedded::ListDecorator.new(
            Affiliate::EventList.find(params[:event_list_id])
          )
          event_list.adpartner_id = params[:adpartner_id]
          @html = ::Liquid::Template.parse(widget.html).render(event_list.context)
          render 'widgets/jsonp/show'
        end
      end
    end
  end
end
