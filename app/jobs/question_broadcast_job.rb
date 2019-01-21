# frozen_string_literal: true

class QuestionBroadcastJob < ApplicationJob
  queue_as :default

  def perform(data)
    ActionCable.server.broadcast 'all_questions', data: data
  end
end
