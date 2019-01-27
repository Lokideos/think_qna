# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable Metrics/BlockLength
RSpec.describe User, type: :model do
  context 'Associations' do
    it { should have_many(:questions) }
    it { should have_many(:answers) }
    it { should have_many(:rewards) }
    it { should have_many(:comments) }
    it { should have_many(:authorizations).dependent(:destroy) }
    it { should have_many(:rating_changes) }
    it { should have_many(:ratings).through(:rating_changes) }
  end

  context 'Methods' do
    describe '#author_of?' do
      let(:user) { create(:user) }
      let(:non_author) { create(:user) }
      let(:question) { create(:question, user: user) }

      context 'For author of the question' do
        it 'should return true' do
          expect(user).to be_author_of(question)
        end
      end

      context 'For user, who is not author of the question' do
        it 'should return false' do
          expect(non_author).to_not be_author_of(question)
        end
      end
    end

    describe '#add_reward' do
      let(:user) { create(:user) }
      let(:question) { create(:question) }
      let(:reward) { create(:reward, question: question) }

      it "should add reward to user's rewards" do
        expect { user.add_reward(reward) }.to change(user.rewards, :count).by(1)
      end

      it "should not add reward to user's rewards if user already posses this reward" do
        user.add_reward(reward)
        expect { user.add_reward(reward) }.to_not change(user.rewards, :count)
      end
    end

    describe '.find_for_oauth' do
      let!(:user) { create(:user) }
      let(:auth) { OmniAuth::AuthHash.new(provider: 'github', uid: '123456') }
      let(:service) { double 'Services::FindForOauth' }

      it 'calls Services::FindForOauth' do
        expect(Services::FindForOauth).to receive(:new).with(auth).and_return(service)
        expect(service).to receive(:call)
        User.find_for_oauth(auth)
      end
    end

    describe '.create_authorization_with_email' do
      let!(:user) { create(:user, email: 'test@test.com') }
      let(:email) { 'test@test.com' }
      let(:bad_email) { 'not_test@test.com' }
      let(:oauth_credentials) { { provider: 'github', uid: '111' } }

      it 'creates authorization for user with provided email' do
        expect do
          User.create_authorization_with_email(email, oauth_credentials[:provider], oauth_credentials[:uid])
        end.to change(Authorization, :count).by(1)
      end

      it 'does not create authorization if email was not provided' do
        expect do
          User.create_authorization_with_email(bad_email, oauth_credentials[:provider], oauth_credentials[:uid])
        end.to_not change(Authorization, :count)
      end
    end

    describe '.exists_with_email?' do
      let!(:user) { create(:user, email: 'test@test.com') }
      let(:good_email) { 'test@test.com' }
      let(:bad_email) { 'bad@email.com' }

      it 'returns true if user with this email exists' do
        expect(User).to be_exists_with_email(good_email)
      end

      it 'returns false if user with this email does not exist' do
        expect(User).to_not be_exists_with_email(bad_email)
      end
    end

    describe '#save_user_for_oauth' do
      let(:user) { build(:user, password: '123456') }
      let!(:password) { user.password }

      it 'assigns password to user' do
        user.save_user_for_oauth
        expect(user.password).to_not eq password
      end

      it 'assigns password confirmation to user' do
        user.save_user_for_oauth
        expect(user.password_confirmation).to_not eq password
      end

      it 'saves the user in the database' do
        expect { user.save_user_for_oauth }.to change(User, :count).by(1)
      end
    end

    def save_user_for_oauth
      self.password = Devise.friendly_token[0, 20]
      self.password_confirmation = password
      save
    end
  end
end
# rubocop:enable Metrics/BlockLength
