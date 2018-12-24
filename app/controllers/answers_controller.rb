# frozen_string_literal: true

class AnswersController < ApplicationController
  before_action :authenticate_user!, except: %i[index show]
  before_action :filter_non_author_users, only: %i[update destroy]

  def show; end

  def edit; end

  def create
    @answer = question.answers.new(answer_params)
    @answer.user = current_user

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

    redirect_to question, notice: 'Answer has been successfully deleted.'
  end

  private

  def filter_non_author_users
    redirect_to root_path unless current_user.author_of?(answer)
  end

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
