# frozen_string_literal: true

class SearchesController < ApplicationController
  authorize_resource

  before_action :load_questions, only: :create

  def create
    @search = Search.new(search_params)

    if search.save
      redirect_to search
    else
      render 'questions/index'
    end
  end

  def show
    @search_result = search.perform_search
  end

  private

  def search_params
    params.require(:search).permit(:query, :search_type)
  end

  def load_questions
    @questions = Question.all
  end

  def search
    @search ||= Search.find(params[:id])
  end

  helper_method :search
end
