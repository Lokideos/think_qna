# frozen_string_literal: true

class Answer < ApplicationRecord
  after_update :two_best_answers_exception

  belongs_to :question
  belongs_to :user

  validates :body, presence: true
  validate :best_answer_uniqueness, on: :create

  # rubocop:disable Style/SafeNavigation
  def choose_best_answer
    previous_answer = question.answers.find_by(best: true)

    Answer.transaction do
      previous_answer.update!(best: false) if previous_answer
      update!(best: true)
    end
  end
  # rubocop:enable Style/SafeNavigation

  default_scope { order(created_at: :asc) }

  private

  def best_answer_uniqueness
    errors.add(:best, I18n.t('errors.best_answer_uniqueness')) if two_best_answer_exists?
  end

  def two_best_answers_exception
    raise StandardError, I18n.t('errors.best_answer_duplicate') if two_best_answer_exists?
  end

  def two_best_answer_exists?
    question && question.answers.where(best: true).length > 1
  end
end
