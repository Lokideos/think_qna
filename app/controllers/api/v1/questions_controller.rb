# frozen_string_literal: true

class Api::V1::QuestionsController < Api::V1::BaseController
  def index
    @questions = Question.all
    render json: @questions
  end

  def show
    @question = Question.find(params[:id])
    render json: @question
  end

  def create
    unauthorized! if current_resource_owner.cannot?(:create, Question)

    @question = Question.new(question_params.merge(user: current_resource_owner))
    @question.save
  end

  def answers
    unauthorized! if cannot? :access, :public_api_call

    @answers = Question.find(params[:id]).answers
    render json: @answers
  end

  private

  def question_params
    params.require(:question).permit(:title, :body)
  end
end
