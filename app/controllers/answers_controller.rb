# frozen_string_literal: true

class AnswersController < ApplicationController
  include Rated

  before_action :authenticate_user!
  before_action :filter_answer_non_author_users, only: %i[update destroy]

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

  def choose_best
    redirect_to root_path, notice: I18n.t('notifications.cherry_request_stub') unless current_user.author_of?(question)

    answer.choose_best_answer
  end

  private

  def load_new_comment
    @comment = answer.comments.build
  end

  def filter_answer_non_author_users
    redirect_to root_path, notice: I18n.t('notifications.cherry_request_stub') unless current_user.author_of?(answer)
  end

  def question
    @question ||= params[:question_id] ? Question.with_attached_files.find(params[:question_id]) : answer.question
  end

  def answer
    @answer ||= params[:id] ? Answer.with_attached_files.find(params[:id]) : question.answers.new
  end

  helper_method :answer, :question

  def answer_params
    params.require(:answer).permit(:body, files: [], links_attributes: %i[name url])
  end
end
