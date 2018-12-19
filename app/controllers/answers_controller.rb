# frozen_string_literal: true

class AnswersController < ApplicationController
  def index
    @answers = Answer.all
  end
end
