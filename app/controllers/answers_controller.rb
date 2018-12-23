# frozen_string_literal: true

class AnswersController < ApplicationController
  before_action :authenticate_user!, except: %i[index show]

  def index
    @answers = Answer.all
  end

  def show; end

  def new; end

  def edit; end

  def create
    @answer = question.answers.new(answer_params)

    if answer.save
      redirect_to question, notice: 'Answer was successfully created.'
    else
      redirect_to question, notice: "Answer wasn't created; check your input."
    end
  end

  def update
    if answer.update(answer_params)
      redirect_to question
    else
      render :edit
    end
  end

  def destroy
    answer.destroy

    redirect_to question
  end

  private

  def question
    @question ||= params[:question_id] ? Question.find(params[:question_id]) : answer.question
  end

  def answer
    @answer ||= params[:id] ? Answer.find(params[:id]) : question.answers.new
  end

  def answer_params
    params.require(:answer).permit(:body)
  end
end
