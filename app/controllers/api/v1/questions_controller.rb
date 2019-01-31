# frozen_string_literal: true

class Api::V1::QuestionsController < ApplicationController
  before_action :doorkeeper_authorize!
  skip_authorization_check

  def index
    @questions = Question.all
    render json: @questions
  end

  def show
    @question = Question.find(params[:id])
    render json: @question
  end
end
