class SubscriptionsController < ApplicationController
  def new
  end

  def create
    # Amount in cents
    @amount = 9900

    customer = Stripe::Customer.create(
      email: params[:stripeEmail],
      card: params[:stripeToken],
      description: '$99/month PlanningAlerts subscription'
    )

    charge = Stripe::Charge.create(
      :customer    => customer.id,
      :amount      => @amount,
      :description => 'Rails Stripe customer',
      :currency    => 'aud'
    )

  rescue Stripe::CardError => e
    flash[:error] = e.message
    redirect_to subscriptions_path
  end
end
