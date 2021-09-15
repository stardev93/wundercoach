module RailsAdmin
  module Config
    module Actions
      # Registers a SwitchUser Action for Account and User within Rails Admin
      class SwitchUser < RailsAdmin::Config::Actions::Base
        RailsAdmin::Config::Actions.register(self)
        register_instance_option :member? do
          true
        end
        register_instance_option :pjax? do
          false
        end
        register_instance_option :only do
          %w(Account User)
        end
        register_instance_option :link_icon do
          'fa fa-refresh'
        end
        register_instance_option :controller do
          proc do
            logout
            user = @object.is_a?(User) ? @object : @object.users.reorder(id: :asc).first
            auto_login(user)
            redirect_to main_app.root_url, notice: "You are now logged in as #{user}"
          end
        end
      end
    end
  end
end
