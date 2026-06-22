class CheckoutsController < ApplicationController
  # Assinar exige estar logado (autenticação padrão).
  def create
    plan = Plan.find(params[:plan_id])

    unless Billing.configured?
      redirect_to plans_path, alert: "Pagamentos não configurados: defina STRIPE_SECRET_KEY."
      return
    end

    session = Billing.create_checkout_session(
      user: Current.user,
      plan: plan,
      success_url: checkout_success_url,
      cancel_url: plans_url
    )
    redirect_to session.url, allow_other_host: true
  end

  def success
    redirect_to account_path, notice: "Assinatura concluída! Pode levar alguns segundos para ativar."
  end
end
