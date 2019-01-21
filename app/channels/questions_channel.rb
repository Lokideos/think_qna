# frozen_string_literal: true

class QuestionsChannel < ApplicationCable::Channel
  def subscribed
    stream_from 'all_questions'
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
