# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable Metrics/BlockLength
feature 'User can delete attachment to his answer', "
  In order to keep my answer update
  As a User
  I'd like to be able to delete attachments to my answers
" do
  given(:user) { create(:user) }
  given(:non_author) { create(:user) }
  given(:question) { create(:question, user: user) }
  given!(:answer) { create(:answer, question: question, user: user) }

  background do
    answer.files.attach(create_file_blob)
  end

  context 'Author' do
    background do
      sign_in(user)
      visit question_path(question)
    end

    scenario 'deletes attachment to his answer', js: true do
      within '.answer-attached-files' do
        click_on 'Delete Attachment'
      end

      within '.answer-attached-files' do
        expect(page).to_not have_content 'image.jpg'
      end
    end

    scenario 'deletes attachment to his answer in edit form', js: true do
      within '.answers' do
        click_on 'Edit Answer'
      end

      within '.edit-answer-form' do
        click_on 'Delete Attachment'
        click_on 'Update'
      end

      within '.answer-attached-files' do
        expect(page).to_not have_content 'image.jpg'
      end
    end
  end

  scenario "User tries to delete attachment ot other user's answer", js: true do
    sign_in(non_author)
    visit question_path(question)

    within '.answer-attached-files' do
      expect(page).to_not have_link 'Delete Attachment'
    end
  end

  scenario 'Unauthenticated user tries to delete attachment to answer', js: true do
    visit question_path(question)

    within '.answer-attached-files' do
      expect(page).to_not have_link 'Delete Attachment'
    end
  end
end
# rubocop:enable Metrics/BlockLength
