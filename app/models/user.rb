class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :subscriptions, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates :email_address, presence: true, uniqueness: true,
            format: { with: URI::MailTo::EMAIL_REGEXP, message: "não é válido" }
  validates :password, length: { minimum: 6 }, allow_nil: true

  def active_subscription
    subscriptions.active.order(created_at: :desc).first
  end

  def subscribed?
    active_subscription.present?
  end
end
