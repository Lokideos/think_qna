# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable Metrics/BlockLength
# rubocop:disable Metrics/LineLength
RSpec.describe AnswersController, type: :controller do
  let(:user) { create(:user) }
  let(:non_author) { create(:user) }
  let(:question) { create(:question, user: user) }
  let(:answer) { create(:answer, question: question, user: user) }

  describe 'POST #create' do
    before { login(user) }

    context 'with valid attributes' do
      it 'saves the answer in the database' do
        expect { post :create, params: { answer: attributes_for(:answer), question_id: question }, format: :js }.to change(Answer, :count).by(1)
      end

      it 'saves the correct association to the question' do
        post :create, params: { answer: attributes_for(:answer), question_id: question, format: :js }
        expect(assigns(:answer).question_id).to eq question.id
      end

      it 'saves the correct association to the user' do
        post :create, params: { answer: attributes_for(:answer), question_id: question, user: user, format: :js }
        expect(assigns(:answer).user_id).to eq user.id
      end

      it 'creates rating for the answer' do
        post :create, params: { answer: attributes_for(:answer), question_id: question, user: user, format: :js }
        expect(assigns(:answer).rating).to be_a(Rating)
      end

      it 'render the create view' do
        post :create, params: { answer: attributes_for(:answer), question_id: question, format: :js }
        expect(response).to render_template :create
      end
    end

    context 'with invalid attributes' do
      it 'does not save the answer in the database' do
        expect { post :create, params: { answer: attributes_for(:answer, :invalid), question_id: question }, format: :js }.to_not change(Answer, :count)
      end

      it 're-renders create template' do
        post :create, params: { answer: attributes_for(:answer, :invalid), question_id: question, format: :js }
        expect(response).to render_template :create
      end
    end
  end

  describe 'PATCH #update' do
    context 'used by Authenticated user' do
      before { login(user) }

      it 'assigns the requested answer to @answer' do
        patch :update, params: { id: answer, answer: attributes_for(:answer), format: :js }
        expect(assigns(:answer)).to eq answer
      end

      context 'with valid attributes' do
        it 'changes the answer attributes' do
          patch :update, params: { id: answer, answer: { body: 'new body' }, format: :js }
          answer.reload
          expect(answer.body).to eq 'new body'
        end

        it 'renders update template' do
          patch :update, params: { id: answer, answer: attributes_for(:answer), format: :js }
          expect(response).to render_template :update
        end
      end

      context 'with invalid attributes' do
        before { patch :update, params: { id: answer, answer: { body: nil }, format: :js } }

        it 'does not change the answer attributes' do
          correct_answer_body = answer.body
          answer.reload

          expect(answer.body).to eq correct_answer_body
        end

        it 're-renders update template' do
          expect(response).to render_template :update
        end
      end
    end

    context 'used by user, who is not author of the answer' do
      before { login(non_author) }

      it 'does not update the answer' do
        correct_answer_body = answer.body
        patch :update, params: { id: answer, answer: attributes_for(:answer, body: 'Other users body'), format: :js }
        answer.reload

        expect(answer.body).to eq correct_answer_body
      end

      it 'returns 302 status code' do
        patch :choose_best, params: { id: answer, format: :js }
        expect(response).to have_http_status 302
      end
    end

    context 'used by Unauthenticated user' do
      it 'does not update the answer' do
        correct_answer_body = answer.body
        patch :update, params: { id: answer, answer: attributes_for(:answer, body: 'Unauthenticated users body'), format: :js }
        answer.reload

        expect(answer.body).to eq correct_answer_body
      end

      it 'returns unauthorized 401 status code' do
        patch :update, params: { id: answer, answer: attributes_for(:answer, body: 'Unauthenticated users body'), format: :js }

        expect(response).to have_http_status(401)
      end
    end
  end

  describe 'DELETE #destroy' do
    let!(:answer) { create(:answer, user: user) }

    context 'used by Authenticated user' do
      before { login(user) }

      it 'deletes the answer' do
        expect { delete :destroy, params: { id: answer, format: :js } }.to change(Answer, :count).by(-1)
      end

      it 'render destroy template' do
        delete :destroy, params: { id: answer, format: :js }
        expect(response).to render_template :destroy
      end
    end

    context 'used by user, who is not author of the answer' do
      before { login(non_author) }

      it 'does not delete the answer from the database' do
        expect { delete :destroy, params: { id: answer, format: :js } }.to_not change(Answer, :count)
      end

      it 'returns 302 status code' do
        patch :choose_best, params: { id: answer, format: :js }
        expect(response).to have_http_status 302
      end
    end

    context 'used by Unauthenticated user' do
      it 'does not delete the answer from the database' do
        expect { delete :destroy, params: { id: answer, format: :js } }.to_not change(Answer, :count)
      end

      it 'returns unauthorized 401 status code' do
        delete :destroy, params: { id: answer, format: :js }

        expect(response).to have_http_status(401)
      end
    end
  end

  describe 'PATCH #choose_best' do
    let(:other_answer) { create(:answer, question: question, user: user) }

    context 'used by authenticated user' do
      before { login(user) }

      it 'changes needed answer attributes' do
        patch :choose_best, params: { id: answer, format: :js }
        answer.reload
        expect(answer).to be_best
      end

      it 'changes needed attributes for other answers' do
        other_answer = create(:answer, question: question, best: true)
        patch :choose_best, params: { id: answer, format: :js }
        other_answer.reload
        expect(other_answer).to_not be_best
      end

      it 'renders choose_best template' do
        patch :choose_best, params: { id: answer, format: :js }
        expect(response).to render_template :choose_best
      end

      context 'on answer to question with reward for best answer' do
        let(:question_with_reward) { create(:question, user: user) }
        let!(:reward) { create(:reward, question: question_with_reward) }
        let!(:answer_on_question_with_reward) { create(:answer, question: question_with_reward, user: non_author) }

        it 'add reward to user' do
          expect do
            patch :choose_best, params: { id: answer_on_question_with_reward, format: :js }
          end.to change(non_author.rewards, :count).by(1)
        end

        it 'does not add reward to user if user already has reward for this question' do
          patch :choose_best, params: { id: answer_on_question_with_reward, format: :js }

          expect { patch :choose_best, params: { id: answer_on_question_with_reward, format: :js } }.to_not change(user.rewards, :count)
        end
      end
    end

    context 'used by user, who is not author of the related question' do
      before { login(non_author) }

      it 'does not change best status of the answer' do
        patch :choose_best, params: { id: other_answer, format: :js }
        answer.reload
        expect(answer).to_not be_best
      end

      it 'returns 302 status code' do
        patch :choose_best, params: { id: answer, format: :js }
        expect(response).to have_http_status 302
      end
    end

    context 'used by unauthenticated user' do
      it 'does not change best status of the answer' do
        patch :choose_best, params: { id: other_answer, format: :js }
        answer.reload
        expect(answer).to_not be_best
      end

      it 'returns unauthorized 401 status code' do
        patch :choose_best, params: { id: answer, format: :js }
        expect(response).to have_http_status(401)
      end
    end
  end

  describe 'PATCH #like' do
    context 'used by Authenticated user, who is not author of the answer' do
      before { login(non_author) }

      it 'increases answer ratings score by 1' do
        rating_count = answer.rating.score
        patch :like, params: { id: answer, format: :json }
        answer.reload

        expect(answer.rating.score).to eq rating_count + 1
      end

      it 'returns 200 status' do
        patch :like, params: { id: answer, format: :json }

        expect(response).to have_http_status 200
      end

      context 'second time in a row' do
        before do
          patch :like, params: { id: answer, format: :json }
          answer.reload
        end

        it 'does not change answer rating score' do
          rating_count = answer.rating.score
          patch :like, params: { id: answer, format: :json }
          answer.reload

          expect(answer.rating.score).to eq rating_count
        end

        it 'returns Unprocessable Entity 422 status' do
          patch :like, params: { id: answer, format: :json }

          expect(response).to have_http_status 422
        end
      end
    end

    context 'used by Author of the answer' do
      before { login(user) }

      it 'does not increase answer rating score by 1' do
        rating_count = answer.rating.score
        patch :like, params: { id: answer, format: :json }
        answer.reload

        expect(answer.rating.score).to eq rating_count
      end

      it 'returns Unprocessable Entity 422 status' do
        patch :like, params: { id: answer, format: :json }

        expect(response).to have_http_status 422
      end
    end

    context 'used by Unauthenticated user' do
      it 'does not increase answer rating score by 1' do
        rating_count = answer.rating.score
        patch :like, params: { id: answer, format: :json }
        answer.reload

        expect(answer.rating.score).to eq rating_count
      end

      it 'returns Unauthorized 401 status' do
        patch :like, params: { id: answer, format: :json }

        expect(response).to have_http_status 401
      end
    end
  end

  describe 'PATCH #dislike' do
    context 'used by Authenticated user, who is not author of the answer' do
      before { login(non_author) }

      it 'decreases answer ratings score by 1' do
        rating_count = answer.rating.score
        patch :dislike, params: { id: answer, format: :json }
        answer.reload

        expect(answer.rating.score).to eq rating_count - 1
      end

      it 'returns OK 200 status' do
        patch :dislike, params: { id: answer, format: :json }

        expect(response).to have_http_status 200
      end

      context 'second time in a row' do
        before do
          patch :dislike, params: { id: answer, format: :json }
          answer.reload
        end

        it 'does not change answer rating score' do
          rating_count = answer.rating.score
          patch :dislike, params: { id: answer, format: :json }
          answer.reload

          expect(answer.rating.score).to eq rating_count
        end

        it 'returns Unprocessable Entity 422 status' do
          patch :dislike, params: { id: answer, format: :json }

          expect(response).to have_http_status 422
        end
      end
    end

    context 'used by Author of the answer' do
      before { login(user) }

      it 'does not decrease answer rating score by 1' do
        rating_count = answer.rating.score
        patch :dislike, params: { id: answer, format: :json }
        answer.reload

        expect(answer.rating.score).to eq rating_count
      end

      it 'returns Unprocessable Entity 422 status' do
        patch :dislike, params: { id: answer, format: :json }

        expect(response).to have_http_status 422
      end
    end

    context 'used by Unauthenticated user' do
      it 'does not decrease answer rating score by 1' do
        rating_count = answer.rating.score
        patch :dislike, params: { id: answer, format: :json }
        answer.reload

        expect(answer.rating.score).to eq rating_count
      end

      it 'returns Unauthorized 401 status' do
        patch :dislike, params: { id: answer, format: :json }

        expect(response).to have_http_status 401
      end
    end
  end

  describe 'PATCH #unlike' do
    context 'used by Authenticated user, who is not author of the answer' do
      before { login(non_author) }

      it 'decreases answer ratings score by 1 if was previously liked' do
        patch :like, params: { id: answer, format: :json }
        answer.reload
        rating_count = answer.rating.score
        patch :unlike, params: { id: answer, format: :json }
        answer.reload

        expect(answer.rating.score).to eq rating_count - 1
      end

      it 'increases answer ratings score by 1 if was previously disliked' do
        patch :dislike, params: { id: answer, format: :json }
        answer.reload
        rating_count = answer.rating.score
        patch :unlike, params: { id: answer, format: :json }
        answer.reload

        expect(answer.rating.score).to eq rating_count + 1
      end

      it 'returns OK 200 status' do
        patch :like, params: { id: answer, format: :json }
        patch :unlike, params: { id: answer, format: :json }

        expect(response).to have_http_status 200
      end

      context 'second time in a row' do
        before do
          patch :like, params: { id: answer, format: :json }
          patch :unlike, params: { id: answer, format: :json }
          answer.reload
        end

        it 'does not increase change answer rating' do
          rating_count = answer.rating.score
          patch :unlike, params: { id: answer, format: :json }
          answer.reload

          expect(answer.rating.score).to eq rating_count
        end

        it 'returns Unprocessable Entity 422 status' do
          patch :unlike, params: { id: answer, format: :json }

          expect(response).to have_http_status 422
        end
      end
    end

    context 'used by Author of the answer' do
      before { login(user) }

      it 'does not change answer rating' do
        rating_count = answer.rating.score
        patch :unlike, params: { id: answer, format: :json }
        answer.reload

        expect(answer.rating.score).to eq rating_count
      end

      it 'returns Unprocessable Entity 422 status' do
        patch :unlike, params: { id: answer, format: :json }

        expect(response).to have_http_status 422
      end
    end

    context 'used by Unauthenticated user' do
      it 'does not decrease answer rating score by 1' do
        rating_count = question.rating.score
        patch :unlike, params: { id: question, format: :json }
        question.reload

        expect(question.rating.score).to eq rating_count
      end

      it 'returns Unauthorized 401 status' do
        patch :unlike, params: { id: question, format: :json }

        expect(response).to have_http_status 401
      end
    end
  end
end
# rubocop:enable Metrics/LineLength
# rubocop:enable Metrics/BlockLength
