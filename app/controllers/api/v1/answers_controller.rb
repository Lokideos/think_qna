# frozen_string_literal: true

class Api::V1::AnswersController < Api::V1::BaseController
  authorize_resource class: Answer

  def index
    @answers = question.answers
    render json: @answers
  end

  def show
    render json: answer
  end

  def create
    @answer = question.answers.new(answer_params.merge(user: current_resource_owner))
    head :unprocessable_entity unless @answer.save
  end

  def update
    head :unprocessable_entity unless answer.update(answer_params)
  end

  def destroy
    answer.destroy
  end

  private

  def answer_params
    params.require(:answer).permit(:body)
  end

  def question
    @question ||= Question.find(params[:question_id]) if params[:question_id]
  end

  def answer
    @answer ||= Answer.find(params[:id]) if params[:id]
  end
end
