# frozen_string_literal: true

class Comment < ApplicationRecord
  default_scope { order(created_at: :asc) }

  after_create_commit { CommentBroadcastJob.perform_later prepared_comment_data }

  belongs_to :commentable, polymorphic: true
  belongs_to :user

  validates :body, presence: true

  private

  def prepared_comment_data
    prepared_data = {}
    prepared_data[:comment] = self
    prepared_data[:question_id] = commentable.is_a?(Question) ? commentable.id : commentable.question.id
    prepared_data[:commentable_id] = commentable.id

    prepared_data
  end
end
