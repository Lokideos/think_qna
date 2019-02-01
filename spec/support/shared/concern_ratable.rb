# frozen_string_literal: true

shared_examples_for 'Concern Ratable' do
  context 'Associations' do
    it { should have_one(:rating).dependent(:destroy) }
  end

  context 'Methods' do
    describe '#create_rating' do
      it 'creates rating after resource creation' do
        resource = create(subject.class.to_s.downcase.to_sym)
        expect(Rating.where(ratable_id: resource.id).count).to eq 1
      end

      it 'creates association to new rating for resource after creating resource' do
        expect(create(subject.class.to_s.downcase.to_sym).rating).to be_a(Rating)
      end
    end
  end
end

# describe '#create_rating' do
#   it 'creates rating after question creation' do
#     expect { create(:question) }.to change(Rating, :count).by(1)
#   end
#
#   it 'creates association to new rating for question after creating question' do
#     question = create(:question)
#
#     expect(question.rating).to be_a(Rating)
#   end
# end
