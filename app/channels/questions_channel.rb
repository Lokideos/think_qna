# frozen_string_literal: true

class QuestionsChannel < ApplicationCable::Channel
  def subscribed
    stream_from 'all_questions'
  end
end
