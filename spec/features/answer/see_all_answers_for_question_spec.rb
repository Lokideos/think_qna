# frozen_string_literal: true

require 'rails_helper'

feature 'User can see all related to question answers on its page', "
  In order to solve the problem
  As a user
  I'd like to be able to see all related to question answers on its page
" do

  given(:question) { create(:question) }
  given!(:answers) { create_list(:answer, 4, question: question) }

  scenario 'User see all related answers' do
    visit question_path(question, lang: 'en')

    answers.each do |answer|
      expect(page).to have_content answer.body
    end
  end
end
