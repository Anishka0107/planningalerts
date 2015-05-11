# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  use_vanity
  force_ssl if: :ssl_required?

  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password

  before_filter :load_configuration, :set_view_path

  def authenticate_active_admin_user!
    authenticate_user!
    unless current_user.admin?
      render text: "Not authorised", status: :forbidden
    end
  end

  private

  def load_configuration
    @alert_count = Stat.applications_sent
    @authority_count = Authority.active.count
  end

  def set_view_path
    @themer = ThemeChooser.themer_from_request(request)
    @theme = @themer.theme

    if @theme == "nsw"
      self.prepend_view_path "lib/themes/nsw/views"
    end
  end

  def ssl_required?
    # This method is called before set_view_path so we need to calculate the theme from the
    # request rather than using @theme which isn't yet set
    ::ThemeChooser.themer_from_request(request).theme != "nsw" && !Rails.env.development?
  end
end
