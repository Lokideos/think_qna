# frozen_string_literal: true

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :questions
  has_many :answers
  has_many :rewards
  has_many :rating_changes
  has_many :ratings, through: :rating_changes

  def author_of?(resource)
    resource.user_id == id
  end

  def add_reward(reward)
    rewards << reward
  end
end
