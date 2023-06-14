# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include HykuHelper
  include IiifPrintHelper
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception, prepend: true

  force_ssl if: :ssl_configured?

  helper Openseadragon::OpenseadragonHelper
  # Adds a few additional behaviors into the application controller
  include Blacklight::Controller
  include Hydra::Controller::ControllerBehavior

  # Adds Hyrax behaviors into the application controller
  include Hyrax::Controller

  include Hyrax::ThemedLayoutController
  with_themed_layout '1_column'

  helper_method :current_account, :admin_host?, :render_ocr_snippets
  before_action :authenticate_if_needed
  before_action :require_active_account!, if: :multitenant?
  before_action :set_account_specific_connections!
  before_action :elevate_single_tenant!, if: :singletenant?
  skip_after_action :discard_flash_if_xhr

  rescue_from Apartment::TenantNotFound do
    raise ActionController::RoutingError, 'Not Found'
  end

  protected

    # remove this once we've backported to `IIIFPrintHelper` and update IIIF Print
    def render_ocr_snippets(options = {})
      snippets = options[:value]
      # rubocop:disable Rails/OutputSafety
      snippets_content = [ActionController::Base.helpers.content_tag('div',
                                                                     "... #{snippets.first} ...".html_safe,
                                                                     class: 'ocr_snippet first_snippet')]
      # rubocop:enable Rails/OutputSafety
      if snippets.length > 1
        snippets_content << render(partial: 'catalog/snippets_more',
                                   locals: { snippets: snippets.drop(1),
                                             options: options })
      end
      # rubocop:disable Rails/OutputSafety
      snippets_content.join("\n").html_safe
      # rubocop:enable Rails/OutputSafety
    end

    def is_hidden
      current_account.persisted? && !current_account.is_public?
    end

    def is_api_or_pdf
      request.format.to_s.match('json') ||
        params[:print] ||
        request.path.include?('api') ||
        request.path.include?('pdf')
    end

    def is_staging
      ['staging'].include?(Rails.env)
    end

    ##
    # Extra authentication for palni-palci during development phase
    def authenticate_if_needed
      # Disable this extra authentication in test mode
      return true if Rails.env.test?
      return unless (is_hidden || is_staging) && !is_api_or_pdf

      authenticate_or_request_with_http_basic do |username, password|
        username == "samvera" && password == "hyku"
      end
    end

    def super_and_current_users
      users = Role.find_by(name: 'superadmin')&.users.to_a
      users << current_user if current_user && !users.include?(current_user)
      users
    end

  private

    def require_active_account!
      return unless Settings.multitenancy.enabled
      return if devise_controller?
      raise Apartment::TenantNotFound, "No tenant for #{request.host}" unless current_account.persisted?
    end

    def set_account_specific_connections!
      current_account&.switch!
    end

    def multitenant?
      Settings.multitenancy.enabled
    end

    def singletenant?
      !Settings.multitenancy.enabled
    end

    def elevate_single_tenant!
      AccountElevator.switch!(current_account.cname) if current_account && root_host?
    end

    def root_host?
      Account.canonical_cname(request.host) == Account.root_host
    end

    def admin_host?
      return false unless multitenant?
      Account.canonical_cname(request.host) == Account.admin_host
    end

    def current_account
      @current_account ||= Account.from_request(request)
      @current_account ||= if Settings.multitenancy.enabled
                             Account.new do |a|
                               a.build_solr_endpoint
                               a.build_fcrepo_endpoint
                               a.build_redis_endpoint
                             end
                           else
                             Account.single_tenant_default
                           end
    end

    # Add context information to the lograge entries
    def append_info_to_payload(payload)
      super
      payload[:request_id] = request.uuid
      payload[:user_id] = current_user.id if current_user
      payload[:account_id] = current_account.cname if current_account
    end

    def ssl_configured?
      ActiveRecord::Type::Boolean.new.cast(Settings.ssl_configured)
    end
end
