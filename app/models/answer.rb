# frozen_string_literal: true

class Answer < ApplicationRecord
  belongs_to :question
  belongs_to :user

  validates :body, presence: true
  validate :true_best_answer_uniqueness

  # scope :best_answers_of_related_question, ->(this_answer) { this_answer.question.answers.where(best: true) }
  # validates :best, uniqueness: { scope: :answers_of_related_question }
  # validates :best, uniqueness: {
  #   scope: best_answers_of_related_question(self),
  #   message: 'There can be only one best answer for each question.'
  # }
  # ERROR:
  # Traceback (most recent call last):
  #         4: from (irb):12
  #         3: from app/models/answer.rb:3:in `<main>'
  #         2: from app/models/answer.rb:13:in `<class:Answer>'
  #         1: from app/models/answer.rb:10:in `block in <class:Answer>'
  # NoMethodError (undefined method `question' for #<Class:0x000055c197097aa0>)

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

  def true_best_answer_uniqueness
    errors.add(:best, I18n.t('errors.best_answer_uniqueness')) if best == true && question.answers.find_by(best: true)
  end
end
