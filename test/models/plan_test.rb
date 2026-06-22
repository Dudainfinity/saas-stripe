require "test_helper"

class PlanTest < ActiveSupport::TestCase
  test "formata preço em BRL" do
    assert_equal "R$ 49,00", Plan.new(price_cents: 4900).price_brl
  end

  test "lista de features quebra por linha" do
    plan = Plan.new(features: "A\nB\n\nC")
    assert_equal %w[A B C], plan.feature_list
  end

  test "rótulo do intervalo" do
    assert_equal "/mês", Plan.new(interval: "month").interval_label
    assert_equal "/ano", Plan.new(interval: "year").interval_label
  end

  test "exige nome" do
    assert_not Plan.new(name: nil).valid?
  end
end
