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

  def create
    @question = Question.find(params[:question_id])
    @answer = @question.answers.new(answer_params)

    if @answer.save
      redirect_to @question
    else
      render :new
    end
  end

  private

  def load_answer
    @answer = Answer.find(params[:id])
  end

  def answer_params
    params.require(:answer).permit(:body)
  end
end
