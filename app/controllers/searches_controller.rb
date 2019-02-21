# frozen_string_literal: true

class SearchesController < ApplicationController
  skip_authorization_check

  def general_search
    authorize! :search, :general_search

    if search_service.valid?
      redirect_to action: 'search_result', search_type: params['search_type'], query: params['query']
    else
      redirect_to questions_path
    end
  end

  def search_result
    authorize! :search, :search_result

    @search_result = search_service.call
  end

  private

  def search_service
    Services::Search.new(params['query'], params['search_type'])
  end
end
