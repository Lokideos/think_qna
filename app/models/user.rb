# frozen_string_literal: true

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
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

  def self.find_for_oauth(auth)
    Services::FindForOauth.new(auth).call
  end

  def create_authorization(auth)
    authorizations.create(provider: auth.provider, uid: auth.uid)
  end
end
