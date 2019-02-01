# frozen_string_literal: true

class Api::V1::AnswersController < Api::V1::BaseController
  def show
    @answer = Answer.find(params[:id])
    render json: @answer
  end

  def create
    unauthorized! if current_resource_owner.cannot? :create, Answer

    @answer = question.answers.new(answer_params.merge(user: current_resource_owner))
    head :unprocessable_entity unless @answer.save
  end

  private

  def answer_params
    params.require(:answer).permit(:body)
  end

  def question
    @question ||= Question.find(params[:question_id]) if params[:question_id]
  end
end
