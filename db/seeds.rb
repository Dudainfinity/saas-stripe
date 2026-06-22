# Planos de demonstração. Em produção, o stripe_price_id viria do painel da Stripe.
Plan.find_or_create_by!(name: "Starter") do |p|
  p.price_cents = 0
  p.interval = "month"
  p.stripe_price_id = "price_starter_demo"
  p.features = "1 projeto\nAté 3 membros\nSuporte por e-mail"
end

Plan.find_or_create_by!(name: "Pro") do |p|
  p.price_cents = 4900
  p.interval = "month"
  p.stripe_price_id = "price_pro_demo"
  p.features = "Projetos ilimitados\nAté 20 membros\nRelatórios avançados\nSuporte prioritário"
end

Plan.find_or_create_by!(name: "Business") do |p|
  p.price_cents = 14900
  p.interval = "month"
  p.stripe_price_id = "price_business_demo"
  p.features = "Tudo do Pro\nMembros ilimitados\nSSO e auditoria\nGerente de conta dedicado"
end

puts "Planos: #{Plan.count}"
