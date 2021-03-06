# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable Metrics/BlockLength
feature 'User can create comments for answers', "
  In order to be able to add reactions to answers
  As Authenticated User
  I'd like to be able to create comments for answers
" do
  given(:user) { create(:user) }
  given(:question) { create(:question) }
  given!(:answer) { create(:answer, question: question) }

  context 'Authenticated user' do
    before { sign_in(user) }

    scenario 'Authenticated user creates comment for answer', js: true do
      visit question_path(question)

      within '.answers .answer-comments .new-comment' do
        fill_in 'Body', with: 'New comment'

        click_on 'Create'
      end

      within '.answers' do
        expect(page).to have_content 'New comment'
      end
    end

    scenario 'Authenticated user tries to create comment for answer with invalid attributes', js: true do
      visit question_path(question)

      within '.answers .answer-comments .new-comment' do
        click_on 'Create'
      end

      within '.answers' do
        expect(page).to have_content("Body can't be blank")
      end
    end
  end

  scenario 'Unauthenticated user tries to create comment for answer' do
    visit question_path(question)

    within '.answers .answer-comments' do
      expect(page).to_not have_link 'Create'
    end
  end

  context 'multiple sessions' do
    scenario "on question's page user sees newly created by other user comment for answer", js: true do
      Capybara.using_session('user') do
        sign_in(user)
        visit question_path(question)
      end

      Capybara.using_session('guest') do
        visit question_path(question)
      end

      Capybara.using_session('user') do
        within '.answers .answers-list .answer-comments .new-comment' do
          fill_in 'Body', with: 'Comment Body Text'

          click_on 'Create'
        end

        within '.answers .answers-list .answer-comments .comments-list' do
          expect(page).to have_content 'Comment Body Text'
        end
      end

      Capybara.using_session('guest') do
        within '.answers .answers-list .answer-comments .comments-list' do
          expect(page).to have_content 'Comment Body Text'
        end
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
