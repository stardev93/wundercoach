class Eventtemplate < Event
  # Find and render a widget via jsonp
  class WidgetsController < ApplicationController
    skip_before_action :set_locale
    skip_before_action :require_login
    skip_before_action :set_tenant_and_account
    skip_before_action :verify_authenticity_token

    def show
      respond_to do |format|
        format.js do

          @widget = Widget.find_by_token(params[:widget_token])
          set_current_tenant @widget.account
          @eventtemplate_obj = Eventtemplate.find_by(slug: params[:eventtemplate_slug], account_id: @widget.account_id)
          #Error handling: Eventtemplate found by slug?
          if @eventtemplate_obj
            @eventtemplate = Embedded::EventtemplateDecorator.new(@eventtemplate_obj)
            @html = ::Liquid::Template.parse(@widget.html).render(@eventtemplate.context)
            view_to_render = 'widgets/jsonp/show'
          else
            @html = "<h3 style=\"text-align: center;\">Wundercoach Eventtemplate with slug '#{params[:eventtemplate_slug]}' not found</h3>"
          end
          render 'widgets/jsonp/show'
        end
      end
    end
  end
end
