# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable Metrics/BlockLength
RSpec.describe Services::GistReadService do
  let!(:user) { create(:user) }
  let(:auth) { OmniAuth::AuthHash.new(provider: 'github', uid: '123456') }
  subject { Services::FindForOauth.new(auth) }

  context 'user already has authorization' do
    it 'returns the user' do
      user.authorizations.create(provider: 'github', uid: '123456')
      expect(subject.call).to eq user
    end
  end

  context 'user has no authorization' do
    context 'user already exists' do
      let(:auth) { OmniAuth::AuthHash.new(provider: 'github', uid: '123456', info: { email: user.email }) }

      it 'does not create new user' do
        expect { subject.call }.to_not change(User, :count)
      end

      it 'creates authorization for user' do
        expect { subject.call }.to change(user.authorizations, :count).by(1)
      end

      it 'creates authorization with provider with uid' do
        authorization = subject.call.authorizations.first

        expect(authorization.provider).to eq auth.provider
        expect(authorization.uid).to eq auth.uid
      end

      it 'returns the user' do
        expect(subject.call).to eq user
      end
    end

    context 'user does not exist' do
      let(:auth) { OmniAuth::AuthHash.new(provider: 'github', uid: '123456', info: { email: 'new@user.com' }) }

      it 'creates new user' do
        expect { subject.call }.to change(User, :count).by(1)
      end

      it 'returns new user' do
        expect(subject.call).to be_a(User)
      end

      it 'fills user email' do
        user = subject.call
        expect(user.email).to eq auth.info[:email]
      end

      it 'creates authorization for user' do
        user = subject.call
        expect(user.authorizations).to_not be_empty
      end

      it 'creates authorization with correct provider and uid' do
        authorization = subject.call.authorizations.first

        expect(authorization.provider).to eq auth.provider
        expect(authorization.uid).to eq auth.uid
      end
    end
  end

  context 'provider did not provide email' do
    let(:auth) { OmniAuth::AuthHash.new(provider: 'github', uid: '123456') }

    it 'returns new user object' do
      expect(subject.call).to be_a(User)
    end

    it 'returns non persisted user object' do
      expect(subject.call).to_not be_persisted
    end
  end
end
# rubocop:enable Metrics/BlockLength
