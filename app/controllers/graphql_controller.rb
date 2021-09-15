class GraphqlController < ApplicationController
  # If accessing from outside this domain, nullify the session
  # This allows for outside API access while preventing CSRF attacks,
  # but you'll have to authenticate your user separately
  # protect_from_forgery with: :null_session
  # skip_before_action :require_login, only: %i(execute)
  # skip_authorization_check
  skip_before_action :set_locale
  skip_before_action :require_login
  skip_before_action :set_tenant_and_account
  skip_before_action :verify_authenticity_token
  # before_action :set_tenant
  # skip_before_action :set_tenant_and_account, only: :not_found

  # Version with access control for feature api (enterprise plan)
  # def execute
  #   variables = ensure_hash(params[:variables])
  #   query = params[:query]
  #   token = request.headers["token"]
  #   # clientsecret = request.headers["clientsecret"]
  #   operation_name = params[:operationName]
  #
  #   # is feature api included in plan
  #   if can? :access, Feature.find_by(key: 'api')
  #     context = {
  #       current_tenant: set_tenant(token)
  #     }
  #   # no
  #   else
  #     context = {
  #       access_rights_error: 'Insufficient rights'
  #     }
  #   end
  #
  #   if context[:current_tenant]
  #     result = WundercoachSchema.execute(query, variables: variables, context: context, operation_name: operation_name)
  #   elsif context[:access_rights_error]
  #     result = { "errors":
  #       ["message": "Insufficient rights error."]
  #     }
  #   else
  #     result = { "errors":
  #       ["message": "Authentication error."]
  #     }
  #   end
  #   render json: result
  # rescue => e
  #   # raise e unless Rails.env.development?
  #   # handle_error_in_development e
  # end

  def execute
    variables = ensure_hash(params[:variables])
    query = params[:query]
    token = request.headers["token"]
    # clientsecret = request.headers["clientsecret"]
    operation_name = params[:operationName]

    context = {
      current_tenant: set_tenant(token)
    }
    if context[:current_tenant]
      result = WundercoachSchema.execute(query, variables: variables, context: context, operation_name: operation_name)
    else
      result = { "errors":
        ["message": "Authentication error."]
      }
    end
    render json: result
  rescue => e
    # raise e unless Rails.env.development?
    # handle_error_in_development e
  end

  private
  # no tenancy through subdomain here, set the tenant by account.token
  def set_tenant(token)
    @account = Account.find_by(token: token)
    if @account
      set_current_tenant @account
    else
      #raise "incorrect token"
      #raise GraphQL::ExecutionError.new('incorrect token')
      nil
    end
  end

  # Handle form data, JSON body, or a blank value
  def ensure_hash(ambiguous_param)
    case ambiguous_param
    when String
      if ambiguous_param.present?
        ensure_hash(JSON.parse(ambiguous_param))
      else
        {}
      end
    when Hash, ActionController::Parameters
      ambiguous_param
    when nil
      {}
    else
      raise ArgumentError, "Unexpected parameter: #{ambiguous_param}"
    end
  end

  def resolve(current_tenant)
    raise GraphQL::ExecutionError.new('permission denied', extensions: { code: 'AUTHENTICATION_ERROR' }) unless context[:current_tenant]
  end

  def handle_error_in_development(e)
    logger.error e.message
    logger.error e.backtrace.join("\n")

    render json: { error: { message: e.message, backtrace: e.backtrace }, data: {} }, status: 500
  end
end
