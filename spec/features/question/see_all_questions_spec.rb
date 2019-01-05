# frozen_string_literal: true

require 'rails_helper'

feature 'User can ses all created questions', "
  In order to answer to the question
  As a user
  I'd like to be able to see all created questions
" do

  given!(:questions) { create_list(:question, 3) }

  scenario 'User can see all created questions' do
    visit questions_path(lang: 'en')

    questions.each { |question| expect(page).to have_content question.title }
  end
end
