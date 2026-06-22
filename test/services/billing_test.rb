require "test_helper"

class BillingTest < ActiveSupport::TestCase
  setup do
    @user = User.create!(email_address: "cliente@exemplo.com", password: "senha123")
    @plan = Plan.create!(name: "Pro", price_cents: 4900, interval: "month", stripe_price_id: "price_x")
  end

  # Simula o payload que a Stripe envia no webhook quando o checkout é concluído.
  def completed_event(user_id:, plan_id:, sub_id: "sub_123")
    {
      "type" => "checkout.session.completed",
      "data" => { "object" => {
        "subscription" => sub_id,
        "metadata" => { "user_id" => user_id.to_s, "plan_id" => plan_id.to_s }
      } }
    }
  end

  test "checkout concluído cria uma assinatura ativa" do
    assert_difference("Subscription.count", 1) do
      Billing.fulfill(completed_event(user_id: @user.id, plan_id: @plan.id))
    end
    sub = @user.subscriptions.last
    assert sub.active?
    assert_equal "sub_123", sub.stripe_subscription_id
    assert_equal @plan, sub.plan
  end

  test "evento sem usuário/plano válidos não cria assinatura" do
    assert_no_difference("Subscription.count") do
      Billing.fulfill(completed_event(user_id: 0, plan_id: 0))
    end
  end

  test "cancelamento marca a assinatura como cancelada" do
    sub = @user.subscriptions.create!(plan: @plan, status: "active", stripe_subscription_id: "sub_999")
    event = {
      "type" => "customer.subscription.deleted",
      "data" => { "object" => { "id" => "sub_999" } }
    }
    Billing.fulfill(event)
    assert_not sub.reload.active?
    assert_equal "canceled", sub.status
  end

  test "eventos desconhecidos são ignorados sem erro" do
    assert_nothing_raised do
      Billing.fulfill({ "type" => "invoice.paid", "data" => { "object" => {} } })
    end
  end
end
