<div align="center">
  <h1>PaceFlow — SaaS com assinaturas e Stripe</h1>
  <p><strong>Aplicação SaaS em Ruby on Rails 8 com login, planos e pagamento recorrente via Stripe.</strong></p>
</div>

<div align="center">
  <img src="docs/planos.png" alt="Página de planos" width="760" />
</div>

---

## Visão geral

Um SaaS funcional com **autenticação**, **página de planos** e **assinatura recorrente**
processada pela **Stripe**. Integração com gateway de pagamento é uma habilidade muito
valorizada — quase todo produto cobra de alguém — e este projeto mostra o fluxo completo:
do checkout ao **webhook** que ativa a assinatura.

## Fluxo de assinatura

```
1. Usuário escolhe um plano        ──►  CheckoutsController#create
2. Billing cria a Checkout Session ──►  redirect para o Stripe (pagamento seguro)
3. Stripe processa o pagamento
4. Stripe chama nosso webhook      ──►  WebhooksController#stripe
5. Billing.fulfill ativa a         ──►  Subscription fica "active"
   assinatura do usuário
```

A reconciliação não depende do redirect de sucesso (que o usuário pode fechar): a
**fonte da verdade é o webhook**, o jeito correto de confirmar pagamentos.

## Arquitetura

- **`Billing`** ([app/services/billing.rb](app/services/billing.rb)) — encapsula toda a
  API da Stripe. O resto da aplicação chama `Billing.*` e não conhece o SDK, o que
  facilita testar (basta simular o payload) e isolar o provedor.
- **`Plan`** — nome, preço (em centavos), intervalo e `stripe_price_id`.
- **`Subscription`** — liga `User` e `Plan`, com status (`active`, `canceled`...).
- **Webhook idempotente** — `checkout.session.completed` ativa, `customer.subscription.deleted` cancela.

## Funcionalidades

- Cadastro, login e logout (autenticação nativa do Rails 8)
- Página de planos (pricing) com destaque para o plano popular
- Checkout recorrente via Stripe Checkout
- Webhook que ativa/cancela a assinatura
- Página "Minha conta" com o status da assinatura

## Configuração da Stripe

A aplicação roda sem chave (a página de planos é pública), mas para o checkout real
defina as chaves de **teste** da Stripe:

```bash
export STRIPE_SECRET_KEY="sk_test_..."
export STRIPE_WEBHOOK_SECRET="whsec_..."
```

Ou via `bin/rails credentials:edit`:

```yaml
stripe:
  secret_key: sk_test_...
  webhook_secret: whsec_...
```

Para receber webhooks localmente: `stripe listen --forward-to localhost:3000/webhooks/stripe`.

## Como rodar

```bash
git clone https://github.com/Dudainfinity/saas-stripe.git
cd saas-stripe
bundle install
bin/rails db:prepare db:seed
bin/rails server
```

## Testes

```bash
bin/rails test
```

A suíte cobre os modelos e — o mais importante — o **`Billing.fulfill`**: simula o
payload do webhook da Stripe e verifica que a assinatura é ativada e cancelada
corretamente, **sem fazer chamadas reais à API**.

## Stack

| Camada        | Tecnologia                       |
|---------------|----------------------------------|
| Framework     | Ruby on Rails 8.1                |
| Autenticação  | Authentication nativa do Rails 8 |
| Pagamentos    | Stripe (gem `stripe`)            |
| Banco         | SQLite                           |
| Testes        | Minitest                         |

---

Desenvolvido por [Dudainfinity](https://github.com/Dudainfinity).
