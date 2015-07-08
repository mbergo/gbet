class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def check_facebook_login
    facebook_info = Facebook::Request.parse_signed_request(cookies["fbsr_#{ENV['FACEBOOK_ID']}"], ENV['FACEBOOK_SECRET'])
    @facebook_id = facebook_info["user_id"]
  rescue
    redirect_to root_path
  end

  def current_user
    @user ||= User.from_id("fb_#{@facebook_id}")
  end


  # AngularJS compatible XSRF
  after_filter :set_csrf_cookie_for_ng

  def set_csrf_cookie_for_ng
    cookies['XSRF-TOKEN'] = form_authenticity_token if protect_against_forgery?
  end

  protected
    def verified_request?
      super || form_authenticity_token == request.headers['X-XSRF-TOKEN']
    end

    def append_info_to_payload(payload)
      super
      payload[:facebook_id] = @facebook_id
    end
end
