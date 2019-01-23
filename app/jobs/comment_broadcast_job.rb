# frozen_string_literal: true

class CommentBroadcastJob < ApplicationJob
  queue_as :default

  def perform(data)
    ActionCable.server.broadcast "comments_#{data[:question_id]}", data: data
  end
end
