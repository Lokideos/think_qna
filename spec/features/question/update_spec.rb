# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable Metrics/BlockLength
feature 'User can update his question', "
  In order to correct mistakes or to specify the question
  As a User
  I'd like to be able to update my question
" do
  given(:user) { create(:user) }
  given(:non_author) { create(:user) }
  given(:question) { create(:question, user: user) }

  context 'Authenticated User' do
    context 'and Author of the question' do
      background do
        sign_in(user)

        visit question_path(question)
      end

      scenario 'updates the question', js: true do
        click_on 'Edit Question'

        within '.question' do
          fill_in 'Title', with: 'Updated Question'
          click_on 'Update'
        end

        expect(page).to have_content 'Your Question has been successfully updated.'
        expect(page).to have_content 'Updated Question'
      end

      scenario 'tries to update the question with invalid attributes', js: true do
        click_on 'Edit Question'

        within '.question' do
          fill_in 'Title', with: ''
          click_on 'Update'
        end

        expect(page).to have_content 'There were errors in your input.'
        within '.question' do
          expect(page).to have_content "Title can't be blank"
        end
      end

      context 'updates the question and attach files' do
        background do
          click_on 'Edit Question'

          within '.edit-question-form' do
            fill_in 'Title', with: 'Updated Question'

            attach_file 'File', ["#{Rails.root}/spec/rails_helper.rb", "#{Rails.root}/spec/spec_helper.rb"]
            click_on 'Update'
          end
        end

        scenario 'successfully', js: true do
          wait_for_ajax
          sleep(2)

          within '.question' do
            expect(page).to have_link 'rails_helper.rb'
            expect(page).to have_link 'spec_helper.rb'
          end
        end

        scenario 'then reload page and see attached files', js: true do
          sleep(2)
          page.evaluate_script 'window.location.reload()'

          click_on 'Edit Question'

          within '.question' do
            expect(page).to have_link 'rails_helper.rb'
            expect(page).to have_link 'spec_helper.rb'
          end
        end

        context 'decides to attach another file without reloading the page and' do
          scenario 'see attached files', js: true do
            click_on 'Edit Question'

            within '.question' do
              expect(page).to have_link 'rails_helper.rb'
              expect(page).to have_link 'spec_helper.rb'
            end
          end

          scenario 'see empty file upload path', js: true do
            wait_for_ajax
            click_on 'Edit Question'

            within '.edit-question-form' do
              click_on 'Update'
            end

            within '.question' do
              expect(page).to have_selector('.attached-file-link', count: 2)
            end
          end
        end
      end

      context 'updates the question and attach link' do
        given(:gist_url) { 'https://gist.github.com/Lokideos/815f3eea3f00a35ff48ea2984457b673' }

        background do
          click_on 'Edit Question'

          within '.edit-question-form' do
            fill_in 'Title', with: 'Updated Question'
          end
        end

        scenario 'with invalid url address', js: true do
          within '.edit-question-form' do
            fill_in 'Link name', with: 'My Gist'
            fill_in 'Url', with: gist_url

            click_on 'Update'
          end

          wait_for_ajax

          within '.question' do
            expect(page).to have_link 'My Gist', href: gist_url
          end
        end

        scenario 'empty link input field after attachin the url', js: true do
          within '.edit-question-form' do
            fill_in 'Link name', with: 'My Gist'
            fill_in 'Url', with: gist_url

            click_on 'Update'
          end

          wait_for_ajax

          click_on 'Edit Question'

          within '.edit-question-form' do
            expect(page).to_not have_content 'My Gist'
            expect(page).to_not have_content gist_url
          end
        end

        scenario 'within invalid url address', js: true do
          within '.edit-question-form' do
            fill_in 'Link name', with: 'Bad Address'
            fill_in 'Url', with: 'Bad URL Address'

            click_on 'Update'
          end

          wait_for_ajax

          within '.question' do
            expect(page).to_not have_link 'Bad Address', href: gist_url
            expect(page).to have_content 'Links url should be correct url address.'
          end
        end
      end
    end

    context 'but non Author of the question' do
      background do
        sign_in(non_author)
      end

      scenario "tries to update other user's question", js: true do
        visit question_path(question)

        expect(page).to_not have_link 'Edit Question'
      end
    end
  end

  context 'Unauthenticated User' do
    scenario 'tries to update the question', js: true do
      visit question_path(question)

      expect(page).to_not have_link 'Edit Question'
    end
  end
end
# rubocop:enable Metrics/BlockLength
