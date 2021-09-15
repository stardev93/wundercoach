class Account < ApplicationRecord
  # only used for updating preferences via ajax
  class PreferencesController < ApplicationController
    # PATCH/PUT /de/account/preferences
    def update
      respond_to do |format|
        format.json do
          @account.update!(preferences_params)
          head :ok
        end
      end
    end

    private

    def preferences_params
      params.require(:account).permit(:show_get_started_modal)
    end
  end
end
