# frozen_string_literal: true

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable,
         :omniauthable, omniauth_providers: [:github]

  has_many :questions
  has_many :answers
  has_many :rewards
  has_many :comments
  has_many :authorizations, dependent: :destroy
  has_many :rating_changes
  has_many :ratings, through: :rating_changes

  def author_of?(resource)
    resource.user_id == id
  end

  def add_reward(reward)
    rewards << reward
  end

  def create_authorization(auth)
    authorizations.create(provider: auth.provider, uid: auth.uid)
  end

  def save_user_for_oauth
    self.password = Devise.friendly_token[0, 20]
    self.password_confirmation = password
    save
  end

  class << self
    def find_for_oauth(auth)
      Services::FindForOauth.new(auth).call
    end

    def create_authorization_with_email(email, provider, uid)
      User.find_by(email: email)&.authorizations&.create!(provider: provider, uid: uid)
    end

    def exists_with_email?(email)
      true if User.find_by(email: email)
    end
  end
end
