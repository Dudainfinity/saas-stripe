class Plan < ApplicationRecord
  has_many :subscriptions, dependent: :restrict_with_error

  validates :name, presence: true
  validates :price_cents, numericality: { greater_than_or_equal_to: 0 }

  def price_brl
    ActiveSupport::NumberHelper.number_to_currency(price_cents / 100.0,
      unit: "R$ ", separator: ",", delimiter: ".")
  end

  # Lista de benefícios, uma por linha no campo `features`.
  def feature_list
    features.to_s.split("\n").map(&:strip).reject(&:blank?)
  end

  def interval_label
    interval == "year" ? "/ano" : "/mês"
  end
end
