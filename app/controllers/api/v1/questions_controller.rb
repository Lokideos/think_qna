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
    if @question.save
      render json: @question, status: 201
    else
      head :unprocessable_entity
    end
  end

  def update
    if question.update(question_params)
      render json: question, status: 201
    else
      head :unprocessable_entity
    end
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
