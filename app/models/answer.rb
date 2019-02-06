# frozen_string_literal: true

class Answer < ApplicationRecord
  include Ratable

  default_scope { order(created_at: :asc) }

  after_create_commit :broadcast_answer
  after_create_commit { SendNotificationJob.perform_later(question) }

  has_many :links, dependent: :destroy, as: :linkable
  has_many :comments, dependent: :destroy, as: :commentable

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

  def broadcast_answer
    ActionCable.server.broadcast "question_#{question_id}", data: prepared_answer_data
  end

  def true_best_answer_uniqueness
    errors.add(:best, I18n.t('errors.best_answer_uniqueness')) if best && question.answers.find_by(best: true)
  end

  def prepared_files_data
    prepared_files_data = []
    files.each do |file|
      prepared_files_data << { filename: file.filename.to_s, file_url: file.service_url, file_id: file.id }
    end

    prepared_files_data
  end

  def prepared_links_data
    prepared_links_data = []
    links.each { |link| prepared_links_data << { link_name: link.name, link_url: link.url, link_body: link.body } }
    prepared_links_data
  end

  def prepared_answer_data
    prepared_data = {}
    prepared_data[:answer] = self
    prepared_data[:files] = prepared_files_data
    prepared_data[:links] = prepared_links_data
    prepared_data[:rating] = rating.score

    prepared_data
  end
end
