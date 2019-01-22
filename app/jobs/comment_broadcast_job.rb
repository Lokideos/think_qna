# frozen_string_literal: true

class CommentBroadcastJob < ApplicationJob
  queue_as :default

  def perform(data)
    ActionCable.server.broadcast "question_#{data[:question_id]}", data: data
  end
end
