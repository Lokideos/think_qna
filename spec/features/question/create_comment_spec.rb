# frozen_string_literal: true

require 'rails_helper'

feature 'User can create comments for questions', "
  In order to add reaction to questions
  As Authenticated
  I'd like to be able to create comments for questions
" do
  given(:user) { create(:user) }
  given(:question) { create(:question) }

  scenario 'Authenticated user creates comment', js: true do
    sign_in(user)
    visit question_path(question)

    within '.question-comments .new-comment' do
      fill_in 'Body', with: 'New comment'

      click_on 'Create'
    end

    within '.question-comments' do
      expect(page).to have_content 'New comment'
    end
  end

  scenario 'Unauthenticated user tries to create comment' do
    visit question_path(question)

    within '.question-comments' do
      expect(page).to_not have_link 'Create'
    end
  end
end
