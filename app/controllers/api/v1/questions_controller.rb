# frozen_string_literal: true

class Api::V1::QuestionsController < Api::V1::BaseController
  def index
    @questions = Question.all
    render json: @questions
  end

  def show
    render json: question
  end

  def create
    unauthorized! if current_resource_owner.cannot? :create, Question

    @question = Question.new(question_params.merge(user: current_resource_owner))
    head :unprocessable_entity unless @question.save
  end

  def update
    unauthorized! if current_resource_owner.cannot? :update, question

    head :unprocessable_entity unless question.update(question_params)
  end

  def destroy
    unauthorized! if current_resource_owner.cannot? :destroy, question

    question.destroy
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

  def question
    @question ||= Question.find(params[:id]) if params[:id]
  end
end
