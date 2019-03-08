# frozen_string_literal: true

class Comment < ApplicationRecord
  default_scope { order(created_at: :asc) }

  after_create_commit :broadcast_comment

  belongs_to :commentable, polymorphic: true, touch: true
  belongs_to :user

  validates :body, presence: true

  private

  def broadcast_comment
    ActionCable.server.broadcast "comments_#{prepared_comment_data[:question_id]}", data: prepared_comment_data
  end

  def prepared_comment_data
    prepared_data = {}
    prepared_data[:comment] = self
    prepared_data[:question_id] = commentable.is_a?(Question) ? commentable.id : commentable.question.id
    prepared_data[:commentable_id] = commentable.id

    prepared_data
  end
end
