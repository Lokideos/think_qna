# frozen_string_literal: true

class Api::V1::QuestionsController < Api::V1::BaseController
  authorize_resource class: Question

  def index
    @questions = Question.all
    render json: @questions
  end

  def show
    render json: question
  end

  def create
    @question = Question.new(question_params.merge(user: current_resource_owner))
    head :unprocessable_entity unless @question.save
  end

  def update
    head :unprocessable_entity unless question.update(question_params)
  end

  def destroy
    question.destroy
  end

  private

  def question_params
    params.require(:question).permit(:title, :body)
  end

  def question
    @question ||= Question.find(params[:id]) if params[:id]
  end
end
