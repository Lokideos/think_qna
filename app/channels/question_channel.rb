# frozen_string_literal: true

class QuestionChannel < ApplicationCable::Channel
  def subscribed
    stream_from "question_#{params[:question_id]}"
  end
end
