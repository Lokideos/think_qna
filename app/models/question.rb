# frozen_string_literal: true

class Question < ApplicationRecord
  include Ratable
  include Commentable

  after_create_commit { QuestionBroadcastJob.perform_later self }

  has_many :answers, dependent: :destroy
  has_many :links, dependent: :destroy, as: :linkable
  has_one :reward, dependent: :destroy

  belongs_to :user

  has_many_attached :files

  accepts_nested_attributes_for :links, reject_if: :all_blank
  accepts_nested_attributes_for :reward, reject_if: :all_blank

  validates :title, :body, presence: true
end
