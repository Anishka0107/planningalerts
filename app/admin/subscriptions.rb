ActiveAdmin.register Subscription do
  index do
    column :email
    column :stripe_plan_id
    column :stripe_customer_id
    column :stripe_subscription_id
    column :paid?
    column :trial?
    column :trial_started_at
    column(:active_alerts) { |s| s.alerts.active.count }
    actions
  end

  filter :email
  filter :stripe_customer_id
  filter :stripe_subscription_id
  filter :trial_started_at

  form do |f|
    inputs "Details" do
      input :email
      # TODO: Don't duplicate definition of plan IDs
      input :stripe_plan_id, as: :select, collection: %w(planningalerts-15 planningalerts-34)
      input :stripe_customer_id
      input :stripe_subscription_id
      input :trial_started_at
    end
    actions
  end

  permit_params :email, :stripe_plan_id, :stripe_customer_id, :stripe_subscription_id, :trial_started_at
end
