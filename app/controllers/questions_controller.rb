# frozen_string_literal: true

class QuestionsController < ApplicationController
  before_action :authenticate_user!, except: %i[index show]
  before_action :filter_non_author_users, only: %i[update destroy]

  def index
    @questions = Question.all
  end

  def show
    @answer = question.answers.new
  end

  def new; end

  def edit; end

  def create
    @question = current_user.questions.new(question_params)

    if question.save
      redirect_to @question, notice: 'Your question successfully created.'
    else
      render :new
    end
  end

  def update
    if question.update(question_params)
      redirect_to @question, notice: 'Your question has been successfully updated.'
    else
      flash[:notice] = 'There were errors in your input.'
      render :edit
    end
  end

  def destroy
    question.destroy
    redirect_to questions_path, notice: 'You have successfully deleted the question.'
  end

  private

  # rubocop:disable Metrics/LineLength
  def filter_non_author_users
    redirect_to root_path, notice: 'You can modify or delete only your questions' unless current_user.author_of?(question)
  end
  # rubocop:enable Metrics/LineLength

  def question_params
    params.require(:question).permit(:title, :body)
  end

  def question
    @question ||= params[:id] ? Question.find(params[:id]) : Question.new
  end

  helper_method :question
end
