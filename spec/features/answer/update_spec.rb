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

      context 'updates the answer and attach files' do
        background do
          within '.answers' do
            click_on 'Edit Answer'

            fill_in 'Body', with: 'Updated Answer'

            attach_file 'File', ["#{Rails.root}/spec/rails_helper.rb", "#{Rails.root}/spec/spec_helper.rb"]
            click_on 'Update'
          end
        end

        scenario 'successfully', js: true do
          wait_for_ajax
          sleep(2)

          within '.answers' do
            expect(page).to have_link 'rails_helper.rb'
            expect(page).to have_link 'spec_helper.rb'
          end
        end

        scenario 'does not see attached to this answer files when tries to update other answer', js: true do
          other_answer = create(:answer, question: question, user: user)
          wait_for_ajax

          page.evaluate_script 'window.location.reload()'

          current_answer = page.find("#answer-info-#{other_answer.id}").first(:xpath, './/..')

          within current_answer do
            click_on 'Edit Answer'
          end

          within current_answer do
            expect(page).to_not have_link 'rails_helper.rb'
            expect(page).to_not have_link 'spec_helper.rb'
          end
        end

        scenario 'then reload page and see attached files', js: true do
          wait_for_ajax

          page.evaluate_script 'window.location.reload()'

          within '.answers' do
            click_on 'Edit Answer'
          end

          within '.answers' do
            expect(page).to have_link 'rails_helper.rb'
            expect(page).to have_link 'spec_helper.rb'
          end
        end

        context 'decides to attach another file without reloading the page and' do
          scenario 'see attached files', js: true do
            within '.answers' do
              click_on 'Edit Answer'
            end

            within '.answers' do
              expect(page).to have_link 'rails_helper.rb'
              expect(page).to have_link 'spec_helper.rb'
            end
          end

          scenario 'see empty file upload path', js: true do
            within '.answers' do
              click_on 'Edit Answer'

              click_on 'Update'
            end

            within '.answers' do
              expect(page).to have_selector('.attached-file-link', count: 2)
            end
          end
        end
      end

      context 'updates answer and attach link' do
        given(:gist_url) { 'https://gist.github.com/Lokideos/815f3eea3f00a35ff48ea2984457b673' }

        background do
          within '.answers' do
            click_on 'Edit Answer'

            within '.edit-answer-form' do
              fill_in 'Body', with: 'Updated Answer Body'
            end
          end
        end

        scenario 'successfully', js: true do
          within '.edit-answer-form' do
            fill_in 'Link name', with: 'My Gist'
            fill_in 'Url', with: gist_url

            click_on 'Update'
          end

          wait_for_ajax

          within '.answers' do
            expect(page).to have_link 'My Gist', href: gist_url
          end
        end

        scenario 'empty link input field after attaching the url', js: true do
          within '.edit-answer-form' do
            fill_in 'Link name', with: 'My Gist'
            fill_in 'Url', with: gist_url

            click_on 'Update'
          end

          wait_for_ajax
          sleep(2)

          click_on 'Edit Answer'

          within '.edit-answer-form .answer-links-attach-section' do
            expect(page).to_not have_content 'My Gist'
            expect(page).to_not have_content gist_url
          end
        end

        scenario 'see created links in form during editing answer', js: true do
          within '.edit-answer-form' do
            fill_in 'Link name', with: 'My Gist'
            fill_in 'Url', with: gist_url

            click_on 'Update'
          end

          wait_for_ajax

          click_on 'Edit Answer'

          within '.edit-answer-form .answer-form-attached-links' do
            expect(page).to have_link 'My Gist', href: gist_url
          end
        end

        scenario 'within invalid url address', js: true do
          within '.edit-answer-form' do
            fill_in 'Link name', with: 'Bad Address'
            fill_in 'Url', with: 'Bad URL Address'

            click_on 'Update'
          end

          wait_for_ajax

          within '.all-answers .answer-errors' do
            expect(page).to_not have_link 'Bad Address', href: 'Bad URL Address'
            expect(page).to have_content 'Links url should be correct url address.'
          end
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
