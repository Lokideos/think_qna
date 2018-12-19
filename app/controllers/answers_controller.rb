# frozen_string_literal: true

class AnswersController < ApplicationController
  before_action :load_answer, only: %i[show edit]
  def index
    @answers = Answer.all
  end

  def show; end

  def new
    @answer = Answer.new
  end

  def edit; end

  private

  def load_answer
    @answer = Answer.find(params[:id])
  end
end
