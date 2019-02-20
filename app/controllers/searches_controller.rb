# frozen_string_literal: true

class SearchesController < ApplicationController
  skip_authorization_check

  before_action :update_cookies, only: :general_search

  def general_search
    if search_service.valid?
      redirect_to search_result_searches_path
    else
      redirect_to questions_path
    end
  end

  def search_result
    @search_result = search_service.call
  end

  private

  def update_cookies
    cookies.delete 'search.query'
    cookies.delete 'search.search_type'
    cookies['search.query'] = params['query']
    cookies['search.search_type'] = params['search_type']
  end

  def search_service
    Services::Search.new(cookies['search.query'], cookies['search.search_type'])
  end
end
