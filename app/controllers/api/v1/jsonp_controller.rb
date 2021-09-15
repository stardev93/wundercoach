# API Interface Version 1.0.0
# JsonpController grabs a widget from the widgets list via its token
# widget can do the following things
# - list all Events (future_events that must be online & that are not individual events or individual agreed events)
# - list all Bundles (containing future_events that must be online)
# - list all IndividualEvents agreed events that are online
# - list all events belonging to a template

module Api
  module V1
    # provides a full list of an account's events and a filtering mechanism
    class JsonpController < ApplicationController
      skip_before_action :set_locale
      skip_before_action :require_login
      skip_before_action :set_tenant_and_account
      skip_before_action :verify_authenticity_token
      before_action :set_widget_and_tenant

      def full_filterable_list
        locale_a = params[:locale]
        locale_a.slice! '/' + params[:widget_token] + '.js'
        I18n.locale = locale_a
        #puts "Locale:" + I18n.locale.to_s
        respond_to do |format|
          format.js do
            account = Embedded::AccountDecorator.new(current_tenant)
            @token = @widget.token
            @filters = params[:event].nil? ? {} : filter_params
            # check if params[:eventtemplate_id] is passed in by params
            if params[:eventtemplate_id]
              @filters['search_by_eventtemplate_id'] = params[:eventtemplate_id]
            end

            @html = ::Liquid::Template.parse(@widget.html).render(account.context(@filters))
            # puts params
          end
        end
      end

      def bundle_event_list
        respond_to do |format|
          format.js do
            account = Embedded::AccountDecorator.new(current_tenant)
            @bundles = Embedded::BundleDecorator.decorate_collection(Bundle.online)
            @filters = params[:event].nil? ? {} : filter_params
            @html = ::Liquid::Template.parse(@widget.html).render(account.context(@filters))
            # puts params
          end
        end
      end

      def individual_event_list
        respond_to do |format|
          format.js do
            account = Embedded::AccountDecorator.new(current_tenant)
            @filters = params[:event].nil? ? {} : filter_params
            @html = ::Liquid::Template.parse(@widget.html).render(account.context(@filters))
            # puts params
          end
        end
      end

      def filtered_list
        respond_to do |format|
          format.js do
            account = Embedded::AccountDecorator.new(current_tenant)
            @filters = filter_params
            @html = ::Liquid::Template.parse(@widget.html).render(account.context(@filters))
          end
        end
      end

      private
      # use widget.token to find widget - no tenancy through subdomain here
      def set_widget_and_tenant
        @widget = Widget.find_by_token(params[:widget_token])
        set_current_tenant @widget.account
      end

      def filter_params
        params.require(:event).permit(:search, :search_by_type, :search_by_tags, :search_by_coaches, :search_by_eventtemplate_id, :eventtemplate_id)
      end
    end
  end
end
