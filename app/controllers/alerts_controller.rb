class AlertsController < ApplicationController
  caches_page :statistics

  def widget_prototype
    @alert = Alert.new(address: params[:address], email: params[:email])
    @set_focus_control = params[:address] ? "alert_email" : "alert_address"
  end

  def new
    @alert = Alert.new(address: params[:address], email: params[:email])
    @set_focus_control = params[:address] ? "alert_email" : "alert_address"
  end

  def create
    @address = params[:alert][:address]
    @alert = Alert.new(address: @address, email: params[:alert][:email], radius_meters: zone_sizes['l'], theme: @theme)
    if !@alert.save
      render 'new'
    end
  end

  def confirmed
    @alert = Alert.find_by!(confirm_id: params[:id])
    @alert.confirm!

    if ENV["CREATE_NEW_SUBSCRIPTIONS"] && @alert.email_has_several_other_alerts?
      if @alert.subscription.nil?
        @subscription = Subscription.create!(email: @alert.email, trial_started_at: Date.today, stripe_plan_id: "planningalerts-34")
        @new_subscription = true
      else
        @subscription = @alert.subscription
        @new_subscription = false
      end
    end
  end

  def unsubscribe
    @alert = Alert.find_by_confirm_id(params[:id])
    @alert.update_attribute(:unsubscribed, true) if @alert
  end

  def area
    @zone_sizes = zone_sizes
    @alert = Alert.find_by_confirm_id!(params[:id])
    if request.get?
      @size = @zone_sizes.invert[@alert.radius_meters]
    else
      @alert.radius_meters = @zone_sizes[params[:size]]
      @alert.save!
      render "area_updated"
    end
  end

  def statistics
    # Commented out because this page is killing mysql.
    #@no_confirmed_alerts = Alert.confirmed.count
    #@no_alerts = Alert.count
    # Hmmm... Temporary variable because we're calling a very slow method. Not good.
    #@alerts_in_inactive_areas = Alert.alerts_in_inactive_areas
    #@no_alerts_in_active_areas = @no_alerts - @alerts_in_inactive_areas.count
    #@freq = Alert.distribution_of_lgas(@alerts_in_inactive_areas)
  end

  private

  def zone_sizes
    {'s' => Rails.application.config.planningalerts_small_zone_size,
      'm' => Rails.application.config.planningalerts_medium_zone_size,
      'l' => Rails.application.config.planningalerts_large_zone_size}
  end
end
