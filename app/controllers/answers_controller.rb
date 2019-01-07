# frozen_string_literal: true

class AnswersController < ApplicationController
  before_action :authenticate_user!, except: %i[show]
  before_action :filter_non_author_users, only: %i[update destroy]

  def show; end

  def create
    @answer = question.answers.new(answer_params)
    @answer.user = current_user
    @answer.save
  end

  def update
    answer.update(answer_params)
  end

  def destroy
    answer.destroy
  end

  private

  def filter_non_author_users
    redirect_to root_path, notice: 'You can modify or delete only your answers' unless current_user.author_of?(answer)
  end

  def question
    @question ||= params[:question_id] ? Question.find(params[:question_id]) : answer.question
  end

  def answer
    @answer ||= params[:id] ? Answer.find(params[:id]) : question.answers.new
  end

  helper_method :answer, :question

  def answer_params
    params.require(:answer).permit(:body)
  end
end
