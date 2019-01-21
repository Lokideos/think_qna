# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable Metrics/BlockLength
feature 'User can create answer for the question', "
  In order to solve the requested issue
  As authenticated user
  I'd like to be able to answer the question on its page
" do

  given(:question) { create(:question) }
  given(:user) { create(:user) }

  describe 'Authenticated user' do
    background do
      sign_in(user)

      visit question_path(question)
    end

    scenario 'create answer for the question', js: true do
      fill_in 'Body', with: 'Answer text'
      click_on 'Answer to question'

      expect(page).to have_content 'Your Answer has been successfully created.'
      expect(current_path).to eq question_path(question)
      within '.answers' do
        expect(page).to have_content 'Answer text'
        expect(page).to have_content 'Edit Answer'
      end

      within '.new-answer' do
        expect(find_field(id: 'answer_body').value).to eq ''
      end
    end

    scenario 'tries to create answer with wrong parameters for the question', js: true do
      click_on 'Answer to question'

      expect(page).to have_content "Answer wasn't created; check your input."
      expect(page).to have_content "Body can't be blank"
    end

    scenario 'create answer with attached files for the question', js: true do
      fill_in 'Body', with: 'Answer text'

      within '.new-answer' do
        attach_file 'File', ["#{Rails.root}/spec/rails_helper.rb", "#{Rails.root}/spec/spec_helper.rb"]
        click_on 'Answer to question'
      end

      within '.answers' do
        expect(page).to have_link 'rails_helper.rb'
        expect(page).to have_link 'spec_helper.rb'
      end
    end
  end

  scenario 'Unauthenticated user tries to create answer for the question', js: true do
    visit question_path(question)

    expect(page).to_not have_selector 'textarea'
  end

  context 'multiple sessions' do
    scenario "on question's page user sees newly created by other user answer", js: true do
      Capybara.using_session('user') do
        sign_in(user)
        visit question_path(question)
      end

      Capybara.using_session('guest') do
        visit question_path(question)
      end

      Capybara.using_session('user') do
        within '.new-answer' do
          fill_in 'Body', with: 'Answer text'
          click_on 'Answer to question'
        end

        within '.answers' do
          expect(page).to have_content 'Answer text'
        end
      end

      Capybara.using_session('guest') do
        within '.answers' do
          expect(page).to have_content 'Answer text'
        end
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
