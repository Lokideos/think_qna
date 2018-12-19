# frozen_string_literal: true

class AnswersController < ApplicationController
  before_action :load_question, only: %i[create]
  before_action :load_related_question, only: %i[update destroy]

  def index
    @answers = Answer.all
  end

  def show; end

  def new; end

  def edit; end

  def create
    @answer = @question.answers.new(answer_params)

    if @answer.save
      redirect_to @question
    else
      render :new
    end
  end

  def update
    if answer.update(answer_params)
      redirect_to @question
    else
      render :edit
    end
  end

  def destroy
    answer.destroy

    redirect_to @question
  end

  private

  def load_related_question
    @question = answer.question
  end

  def load_question
    @question = Question.find(params[:question_id])
  end

  def answer
    @answer ||= params[:id] ? Answer.find(params[:id]) : load_question.answers.new
  end

  def answer_params
    params.require(:answer).permit(:body)
  end
end
