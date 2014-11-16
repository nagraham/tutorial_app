require 'spec_helper'

describe "Micropost Pages" do

  subject { page }

  let (:user) { FactoryGirl.create(:user) }
  before { sign_in user }

  describe 'creating a micropost' do
    before { visit root_path }

    context 'with invalid information' do

      it 'should not create a blank micropost' do
        expect { click_button 'Post' }.not_to change(Micropost, :count)
      end

      describe 'error messages' do
        before { click_button 'Post' }
        it { should have_content('error') }
      end
    end

    context 'with valid information' do
      before { fill_in 'micropost_content', with: 'Lorem ipsum' }
      it 'should create a new micropost' do
        expect { click_button 'Post' }.to change(Micropost, :count).by(1)
      end
    end
  end

  describe 'destroying a micropost' do
    before { FactoryGirl.create(:micropost, user: user) }

    describe 'as correct user' do
      before { visit root_path }

      it 'should be able to delete a micropost' do
        expect { click_link 'delete' }.to change(Micropost, :count).by(-1)
      end
    end
  end

end
