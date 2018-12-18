# frozen_string_literal: true

class QuestionsController < ApplicationController
  def index
    @questions = Question.all
  end
end
