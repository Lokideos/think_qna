# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable Metrics/BlockLength
feature 'User can update his answer', "
  In order to correct or specify the answer
  As a User
  I'd like to be able to update my answer
" do
  given(:user) { create(:user) }
  given(:non_author) { create(:user) }
  given(:question) { create(:question) }
  given!(:answer) { create(:answer, question: question, user: user) }

  context 'Authenticated user' do
    context 'as author of answer' do
      background do
        sign_in(user)

        visit question_path(question)
      end

      scenario 'updates his answer', js: true do
        within '.answers' do
          click_on 'Edit Answer'

          fill_in 'Body', with: 'Updated Answer'
          click_on 'Update'
        end

        expect(current_path).to eq question_path(question)
        expect(page).to have_content 'Answer has been successfully updated.'
        within '.answers' do
          expect(page).to have_content 'Updated Answer'
        end
      end

      scenario 'tries to update his answer with invalid attributes', js: true do
        within '.answers' do
          click_on 'Edit Answer'

          fill_in 'Body', with: ''
          click_on 'Update'
        end

        expect(current_path).to eq question_path(question)
        expect(page).to have_content 'There were errors in your input.'
        within '.answers' do
          expect(page).to have_content "Body can't be blank"
        end
      end

      scenario 'attach files to answer while updating the answer', js: true do
        within '.answers' do
          click_on 'Edit Answer'

          fill_in 'Body', with: 'Updated Answer'

          attach_file 'File', ["#{Rails.root}/spec/rails_helper.rb", "#{Rails.root}/spec/spec_helper.rb"]
          click_on 'Update'
        end

        within '.answers' do
          expect(page).to have_link 'rails_helper.rb'
          expect(page).to have_link 'spec_helper.rb'
        end
      end
    end

    context 'not as Author of answer' do
      background { sign_in(non_author) }

      scenario "tries to update other user's answer", js: true do
        visit question_path(question)

        within '.answers' do
          expect(page).to_not have_link 'Edit Answer'
        end
      end
    end
  end

  context 'Unauthenticated user' do
    scenario 'tries to update answer' do
      visit question_path(question)

      within '.answers' do
        expect(page).to_not have_link 'Edit Answer'
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
