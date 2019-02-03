# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
shared_examples_for 'Concern Rated' do
  describe 'PATCH #like' do
    context 'used by Authenticated user, who is not author of the resource' do
      before { login(non_author) }

      it 'increases resource ratings score by 1' do
        rating_count = resource.rating.score
        patch :like, params: { id: resource, format: :json }
        resource.reload

        expect(resource.rating.score).to eq rating_count + 1
      end

      it 'returns 200 status' do
        patch :like, params: { id: resource, format: :json }

        expect(response).to have_http_status 200
      end

      context 'second time in a row' do
        before do
          patch :like, params: { id: resource, format: :json }
          resource.reload
        end

        it 'does not change resource rating score' do
          rating_count = resource.rating.score
          patch :like, params: { id: resource, format: :json }
          resource.reload

          expect(resource.rating.score).to eq rating_count
        end

        it 'returns Forbidden 403 status' do
          patch :like, params: { id: resource, format: :json }

          expect(response).to have_http_status 403
        end
      end
    end

    context 'used by Author of the resource' do
      before { login(user) }

      it 'does not increase resource rating score by 1' do
        rating_count = resource.rating.score
        patch :like, params: { id: resource, format: :json }
        resource.reload

        expect(resource.rating.score).to eq rating_count
      end

      it 'returns Forbidden 403 status' do
        patch :like, params: { id: resource, format: :json }

        expect(response).to have_http_status 403
      end
    end

    context 'used by Unauthenticated user' do
      it 'does not increase resource rating score by 1' do
        rating_count = resource.rating.score
        patch :like, params: { id: resource, format: :json }
        resource.reload

        expect(resource.rating.score).to eq rating_count
      end

      it 'returns Unauthorized 401 status' do
        patch :like, params: { id: resource, format: :json }

        expect(response).to have_http_status 401
      end
    end
  end

  describe 'PATCH #dislike' do
    context 'used by Authenticated user, who is not author of the resource' do
      before { login(non_author) }

      it 'decreases resource ratings score by 1' do
        rating_count = resource.rating.score
        patch :dislike, params: { id: resource, format: :json }
        resource.reload

        expect(resource.rating.score).to eq rating_count - 1
      end

      it 'returns OK 200 status' do
        patch :dislike, params: { id: resource, format: :json }

        expect(response).to have_http_status 200
      end

      context 'second time in a row' do
        before do
          patch :dislike, params: { id: resource, format: :json }
          resource.reload
        end

        it 'does not change resource rating score' do
          rating_count = resource.rating.score
          patch :dislike, params: { id: resource, format: :json }
          resource.reload

          expect(resource.rating.score).to eq rating_count
        end

        it 'returns Forbidden 403 status' do
          patch :dislike, params: { id: resource, format: :json }

          expect(response).to have_http_status 403
        end
      end
    end

    context 'used by Author of the resource' do
      before { login(user) }

      it 'does not decrease resource rating score by 1' do
        rating_count = resource.rating.score
        patch :dislike, params: { id: resource, format: :json }
        resource.reload

        expect(resource.rating.score).to eq rating_count
      end

      it 'returns Forbidden 403 status' do
        patch :dislike, params: { id: resource, format: :json }

        expect(response).to have_http_status 403
      end
    end

    context 'used by Unauthenticated user' do
      it 'does not decrease resource rating score by 1' do
        rating_count = resource.rating.score
        patch :dislike, params: { id: resource, format: :json }
        resource.reload

        expect(resource.rating.score).to eq rating_count
      end

      it 'returns Unauthorized 401 status' do
        patch :dislike, params: { id: resource, format: :json }

        expect(response).to have_http_status 401
      end
    end
  end

  describe 'PATCH #unlike' do
    context 'used by Authenticated user, who is not author of the resource' do
      before { login(non_author) }

      it 'decreases resource ratings score by 1 if was previously liked' do
        patch :like, params: { id: resource, format: :json }
        resource.reload
        rating_count = resource.rating.score
        patch :unlike, params: { id: resource, format: :json }
        resource.reload

        expect(resource.rating.score).to eq rating_count - 1
      end

      it 'increases resource ratings score by 1 if was previously disliked' do
        patch :dislike, params: { id: resource, format: :json }
        resource.reload
        rating_count = resource.rating.score
        patch :unlike, params: { id: resource, format: :json }
        resource.reload

        expect(resource.rating.score).to eq rating_count + 1
      end

      it 'returns OK 200 status' do
        patch :like, params: { id: resource, format: :json }
        patch :unlike, params: { id: resource, format: :json }

        expect(response).to have_http_status 200
      end

      context 'second time in a row' do
        before do
          patch :like, params: { id: resource, format: :json }
          patch :unlike, params: { id: resource, format: :json }
          resource.reload
        end

        it 'does not increase change resource rating' do
          rating_count = resource.rating.score
          patch :unlike, params: { id: resource, format: :json }
          resource.reload

          expect(resource.rating.score).to eq rating_count
        end

        it 'returns Forbidden 403 status' do
          patch :unlike, params: { id: resource, format: :json }

          expect(response).to have_http_status 403
        end
      end
    end

    context 'used by Author of the resource' do
      before { login(user) }

      it 'does not change resource rating' do
        rating_count = resource.rating.score
        patch :unlike, params: { id: resource, format: :json }
        resource.reload

        expect(resource.rating.score).to eq rating_count
      end

      it 'returns Forbidden 403 status' do
        patch :unlike, params: { id: resource, format: :json }

        expect(response).to have_http_status 403
      end
    end

    context 'used by Unauthenticated user' do
      it 'does not decrease resource rating score by 1' do
        rating_count = resource.rating.score
        patch :unlike, params: { id: resource, format: :json }
        resource.reload

        expect(resource.rating.score).to eq rating_count
      end

      it 'returns Unauthorized 401 status' do
        patch :unlike, params: { id: resource, format: :json }

        expect(response).to have_http_status 401
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
