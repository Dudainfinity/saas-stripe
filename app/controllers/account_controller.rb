class AccountController < ApplicationController
  def show
    @subscription = Current.user.active_subscription
  end
end
