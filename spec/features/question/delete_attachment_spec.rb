# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable Metrics/BlockLength
feature 'Author of question deletes attachment to this question', "
  In order to keep attachments up to date
  As Author of the question
  I'd like to be able delete attachments to this question
" do
  given(:user) { create(:user) }
  given(:non_author) { create(:user) }
  given(:question) { create(:question, user: user) }

  context 'creation' do
    background do
      question.files.attach(create_file_blob)
    end

    scenario 'Author deletes the attachment', js: true do
      sign_in(user)
      visit question_path(question)

      within '.question' do
        click_on 'Delete Attachment'
      end

      within '.question' do
        expect(page).to_not have_link 'rails_helper.rb'
      end
    end

    scenario 'Non author tries to delete the attachment', js: true do
      sign_in(non_author)
      visit question_path(question)

      expect(page).to_not have_link 'Delete Attachment'
    end

    scenario 'Unauthenticated user tries to delete the attachment', js: true do
      visit question_path(question)

      expect(page).to_not have_link 'Delete Attachment'
    end
  end
end
# rubocop:enable Metrics/BlockLength
