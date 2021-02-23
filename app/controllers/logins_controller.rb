class LoginsController < ApplicationController
#  before_filter :authorize, :except => [:index, :reset_password, :testemail]
  skip_before_action :authorize, :page_initializer, raise: false
  layout 'portal_login'

  def show
    @user = User.new
    @main_image = 'logos/MACRALoginLogoOptimizer.png'
  end

  def create
    user = User.authenticate(login_params[:email_address], login_params[:password])

    @url_host = request.env['HTTP_HOST']

    @main_image = 'logos/MACRALoginLogoOptimizer.png'
    session[:user_id] = nil
    session[:group_id] = nil
    if user
      if user.active?
        session[:user_id] = user.id
        uri = session[:original_uri]
        session[:original_uri] = nil
        session[:expiry_time] = MAX_SESSION_TIME.seconds.from_now
        if user.force_password_reset?
          flash[:notice] = "<span class='no'>You must reset your password after retrieving from an email.</span>"
          redirect_to controller: 'utilities', action: 'edit_my_account'
        elsif !user.status?
          flash[:notice] = "<span class='no'>Your Account is Locked!  Please contact system adminstrator.</span>"
        else
          if uri == nil
            redirect_to( { controller: 'home', action: 'index'})
          else
            redirect_to(uri)
          end
        end
      else
        flash[:notice] = "<span class='no'>Your user is no longer active.  Please see an administrator if this was done in error.</span>"
      end
    else
      flash[:notice] = "<span class='no'>LOGIN FAILED.  If you have forgotten your password, you can reset it. If you need help, please contact the system administrator.</span>"
      redirect_to login_url
    end
  end

  def destroy
    user = User.find_by_id(session[:user_id])
    user.update_attribute(:last_logout_date, Time.zone.now)
    reset_session
    flash[:notice] = "<span class='yes'>You have successfully logged out.</span>"
    redirect_to login_url
  end

  def reset_password
    if request.post?
      @user_reset = User.find_by_email_address(params[:email_address])
      if @user_reset && @user_reset.active?
        @user_reset.reset_password()
        @user_reset.save
        @url_full = request.url
        @url_host = request.env["HTTP_HOST"]
        # MumMailer.deliver_resetpassword(@user_reset, @url_host)
        flash[:notice] = "<span class='yes'>Your password has been re-set. Please check your E-mail.</span>"
        redirect_to(action: 'index')
      else
        flash[:notice] = "<span class='no'>Reset Password failed. Please make sure you have entered your email address correctly.</span>"
      end
    end
  end

  private

  def login_params
    params.require(:user).permit(:email_address, :password)
  end
end
