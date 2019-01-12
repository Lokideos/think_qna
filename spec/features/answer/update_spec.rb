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
          sleep(3)

          within '.answers' do
            expect(page).to have_link 'rails_helper.rb'
            expect(page).to have_link 'spec_helper.rb'
          end
        end

        scenario 'does not see attached to this answer files when tries to update other answer', js: true do
          other_answer = create(:answer, question: question, user: user)
          sleep(2)

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
          sleep(2)
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
