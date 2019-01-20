# frozen_string_literal: true

class Answer < ApplicationRecord
  include Ratable

  default_scope { order(created_at: :asc) }

  has_many :links, dependent: :destroy, as: :linkable

  belongs_to :question
  belongs_to :user

  has_many_attached :files

  accepts_nested_attributes_for :links, reject_if: :all_blank

  validates :body, presence: true
  validate :true_best_answer_uniqueness

  # rubocop:disable Style/SafeNavigation
  def choose_best_answer
    previous_answer = question.answers.find_by(best: true)

    Answer.transaction do
      previous_answer.update!(best: false) if previous_answer
      update!(best: true)
      user.add_reward(question.reward) if question.reward
    end
  end
  # rubocop:enable Style/SafeNavigation

  private

  def true_best_answer_uniqueness
    errors.add(:best, I18n.t('errors.best_answer_uniqueness')) if best && question.answers.find_by(best: true)
  end
end
