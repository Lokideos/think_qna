# frozen_string_literal: true

class Question < ApplicationRecord
  include Ratable
  include Commentable

  after_create_commit :broadcast_question
  after_create_commit :add_subscription

  scope :newly_created, -> { where('created_at > ?', Time.now - 86_400) }

  has_many :answers, dependent: :destroy
  has_many :links, dependent: :destroy, as: :linkable
  has_many :subscriptions, dependent: :destroy
  has_one :reward, dependent: :destroy

  belongs_to :user

  has_many_attached :files

  accepts_nested_attributes_for :links, reject_if: :all_blank
  accepts_nested_attributes_for :reward, reject_if: :all_blank

  validates :title, :body, presence: true

  def subscribed_users
    users = []
    subscriptions.each do |sub|
      users << sub.user
    end

    users
  end

  private

  def broadcast_question
    ActionCable.server.broadcast 'all_questions', data: self
  end

  def add_subscription
    user.subscribe(self)
  end
end
