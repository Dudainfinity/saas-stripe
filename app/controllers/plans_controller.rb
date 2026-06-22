class PlansController < ApplicationController
  allow_unauthenticated_access only: :index

  def index
    @plans = Plan.order(:price_cents)
    @current_plan_id = authenticated? ? Current.user.active_subscription&.plan_id : nil
  end
end
