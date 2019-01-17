# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable Metrics/BlockLength
feature 'User can rate the question', "
  In order to determine most requested questions
  As a User who is not author of this question
  I'd like to be able rate the question
" do
  given(:user) { create(:user) }
  given(:question_author) { create(:user) }
  given(:question) { create(:question, user: question_author) }
  given!(:rating) { create(:rating, ratable: question) }

  context 'Authenticated user and not author of the question' do
    background { sign_in(user) }

    background { visit question_path(question) }

    scenario 'rates up the question', js: true do
      within '.question-rating' do
        click_on 'Like'
      end
      wait_for_ajax
      sleep(1)

      within '.question-rating .question-rating-value' do
        expect(page).to have_content 'Rating: 1'
      end

      expect(page).to have_content 'You have successfully rated the question.'
    end

    scenario 'rates down the question', js: true do
      within '.question-rating' do
        click_on 'Dislike'
      end
      wait_for_ajax
      sleep(1)

      within '.question-rating .question-rating-value' do
        expect(page).to have_content 'Rating: -1'
      end

      expect(page).to have_content 'You have successfully rated the question.'
    end

    scenario 'tries to rate question up second time', js: true do
      within '.question-rating' do
        click_on 'Like'
      end
      wait_for_ajax
      sleep(1)

      within '.question-rating .question-rating-value' do
        expect(page).to have_content 'Rating: 1'
        expect(page).to_not have_link 'Like'
      end
    end

    scenario 'tries to rate question down second time', js: true do
      within '.question-rating' do
        click_on 'Dislike'
      end
      wait_for_ajax
      sleep(1)

      within '.question-rating .question-rating-value' do
        expect(page).to have_content 'Rating: -1'
        expect(page).to_not have_link 'Dislike'
      end
    end

    context 'after reloading the page does not see rate link and see correct rating' do
      scenario 'after liking the question', js: true do
        new_question = create(:question)
        visit question_path(new_question)

        within '.question-rating' do
          click_on 'Like'
        end
        page.evaluate_script 'window.location.reload()'

        within '.question-rating .question-rating-value' do
          expect(page).to have_content 'Rating: 1'
          expect(page).to_not have_link 'Like'
        end
      end

      scenario 'after disliking the question', js: true do
        another_new_question = create(:question)
        visit question_path(another_new_question)

        within '.question-rating' do
          click_on 'Dislike'
        end
        page.evaluate_script 'window.location.reload()'

        within '.question-rating .question-rating-value' do
          expect(page).to have_content 'Rating: -1'
          expect(page).to_not have_link 'Dislike'
        end
      end
    end

    scenario 'sees the unlike link after he rates the question', js: true do
      within '.question' do
        click_on 'Like'
      end

      within '.question-rating' do
        expect(page).to have_link 'Unlike'
      end
    end

    scenario 'unlikes the quesiton', js: true do
      within '.question' do
        click_on 'Like'
        wait_for_ajax
        click_on 'Unlike'
      end

      within '.question-rating' do
        expect(page).to_not have_link 'Unlike'
      end

      expect(page).to have_content 'You have canceled your vote.'
    end
  end

  scenario 'Author of the question tries to rate the question' do
    sign_in(question_author)
    visit question_path(question)

    within '.question-rating' do
      expect(page).to_not have_link 'Like'
    end
  end

  scenario 'Unauthenticated user tries to rate the question' do
    visit question_path(question)

    within '.question-rating' do
      expect(page).to_not have_link 'Like'
    end
  end
end
# rubocop:enable Metrics/BlockLength
