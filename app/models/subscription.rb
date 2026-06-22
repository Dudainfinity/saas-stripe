class Subscription < ApplicationRecord
  belongs_to :user
  belongs_to :plan

  ACTIVE_STATUSES = %w[active trialing].freeze

  scope :active, -> { where(status: ACTIVE_STATUSES) }

  def active?
    ACTIVE_STATUSES.include?(status)
  end
end
