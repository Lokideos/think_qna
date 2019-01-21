# frozen_string_literal: true

class AnswerBroadcastJob < ApplicationJob
  queue_as :default

  def perform(data)
    ActionCable.server.broadcast "question_#{data[:answer].question.id}", data: data
  end
end
