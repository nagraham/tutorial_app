# Integration Test: Static Pages

# RSPEC: describe block: describe <your test comment> do
# you can add whatever you want to that string;
# hopefully something descriptive  . . .

# RSPEC: verbose way to test
# it 'should have the content \'Tutorial App\'' do
#   expect(page).to have_content('Tutorial App')
# end

require 'spec_helper'

describe 'Static pages' do

  # Use the the let(:symbol) function to define variables across all tests
  # let(:base_title) { 'Ruby on Rails Tutorial App' }

  # define the CAPYBARA subject for our tests; CAPY gives us page variable
  subject{ page }

  describe 'the home page' do

    before { visit root_path }
    it { should have_content('Tutorial App') }
    it { should have_title(full_title('')) }
    # We test that it DOESN'T have the page title because have_title
    # will also just search for sub-strings
    it { should_not have_title('| Home') }

    context 'for signed in users' do
      let(:user) { FactoryGirl.create(:user) }
      before do
        FactoryGirl.create(:micropost, user: user, content: 'Lorem ipsum')
        FactoryGirl.create(:micropost, user: user, content: 'Dolor sit amet')
        sign_in user
        visit root_path
      end

      it 'should render the user\'s feed' do
        user.feed.each do |feed|
          expect(page).to have_selector("li##{feed.id}", text: feed.content)
        end
      end

      describe 'following/followers count' do
        let(:other_user) { FactoryGirl.create(:user) }
        before do
          other_user.follow!(user)
          visit root_path
        end
        it { should have_link('0 following', href: following_user_path(user)) }
        it { should have_link('1 followers', href: followers_user_path(user)) }
      end
    end

  end


  describe 'the help page' do
    before { visit help_path }
    it { should have_content('Help') }
    it { should have_title (full_title('Help'))}
  end

  describe 'the about page' do
    before { visit about_path }
    it { should have_content('About Us') }
    it { should have_title(full_title('About Us')) }
  end

  describe 'the contact page' do
    before { visit contact_path }
    it { should have_content('Contact')}
    it { should have_title(full_title('Contact'))}
  end
end