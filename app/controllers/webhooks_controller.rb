class WebhooksController < ApplicationController
  # Webhooks vêm do Stripe (sem cookie/sessão) — liberamos auth e CSRF.
  allow_unauthenticated_access only: :stripe
  skip_forgery_protection only: :stripe

  def stripe
    payload = request.body.read
    signature = request.env["HTTP_STRIPE_SIGNATURE"]

    event =
      begin
        Stripe::Webhook.construct_event(payload, signature, Billing.webhook_secret)
      rescue JSON::ParserError, Stripe::SignatureVerificationError
        return head :bad_request
      end

    Billing.fulfill(event.to_hash.deep_stringify_keys)
    head :ok
  end
end
