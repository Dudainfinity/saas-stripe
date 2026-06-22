# Encapsula toda a conversa com o Stripe num único lugar.
# O resto da aplicação chama Billing.* e não conhece a API do Stripe — o que
# facilita testar (basta simular estes métodos) e trocar de provedor no futuro.
module Billing
  module_function

  def api_key
    Rails.application.credentials.dig(:stripe, :secret_key) || ENV["STRIPE_SECRET_KEY"]
  end

  def webhook_secret
    Rails.application.credentials.dig(:stripe, :webhook_secret) || ENV["STRIPE_WEBHOOK_SECRET"]
  end

  def configured?
    api_key.present?
  end

  # Cria uma sessão de Checkout do Stripe para o usuário assinar um plano.
  # Os ids de usuário e plano vão em metadata para reconciliar no webhook.
  def create_checkout_session(user:, plan:, success_url:, cancel_url:)
    Stripe.api_key = api_key
    Stripe::Checkout::Session.create(
      mode: "subscription",
      customer_email: user.email_address,
      line_items: [ { price: plan.stripe_price_id, quantity: 1 } ],
      success_url: success_url,
      cancel_url: cancel_url,
      metadata: { user_id: user.id, plan_id: plan.id }
    )
  end

  # Processa um evento recebido no webhook. Recebe um Hash (payload já parseado)
  # para ser facilmente testável sem o SDK do Stripe.
  def fulfill(event)
    case event["type"]
    when "checkout.session.completed"
      activate_from_session(event.dig("data", "object"))
    when "customer.subscription.deleted"
      cancel_from_subscription(event.dig("data", "object"))
    end
  end

  def activate_from_session(session)
    meta = session["metadata"] || {}
    user = User.find_by(id: meta["user_id"])
    plan = Plan.find_by(id: meta["plan_id"])
    return unless user && plan

    sub = user.subscriptions.find_or_initialize_by(plan: plan)
    sub.update!(
      status: "active",
      stripe_subscription_id: session["subscription"]
    )
    sub
  end

  def cancel_from_subscription(stripe_sub)
    sub = Subscription.find_by(stripe_subscription_id: stripe_sub["id"])
    sub&.update!(status: "canceled")
  end
end
