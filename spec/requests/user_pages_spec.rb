require 'spec_helper'

describe "User pages" do

  subject { page }

  #
  # --- User Index Page---
  #
  describe 'index page' do
    before do
      sign_in FactoryGirl.create(:user)
      visit users_path
    end

    it { should have_title('All Users') }
    it { should have_content('All Users') }

    # NOTE: Pagination is provided by will_pagination gem
    describe 'pagination' do
      # before(:all) creates 30 users only ONCE
      before(:all) { 30.times { FactoryGirl.create(:user) } }
      after(:all)  { User.delete_all }

      it { should have_selector('div.pagination') }
    end

    it 'should list each user' do
      User.paginate(page: 1).each do |user|
        expect(page).to have_selector('li', text: user.name)
      end
    end

    describe 'delete links' do

      it { should_not have_link('delete') }

      describe 'as an admin user' do
        let(:admin) { FactoryGirl.create(:admin) }
        before do
          sign_in admin
          visit users_path
        end

        it { should have_link('delete', href: user_path(User.first)) }
        it 'should be able to delete another user' do
          expect do
            click_link('delete', match: :first)
          end.to change(User, :count).by(-1)
        end
        it { should_not have_link('delete', href: user_path(admin)) }
      end
    end
  end

  #
  # --- Profile Page---
  #
  describe 'profile page' do
    let(:user) { FactoryGirl.create(:user) }
    let!(:m1) { FactoryGirl.create(:micropost, user: user, content: 'Foo') }
    let!(:m2) { FactoryGirl.create(:micropost, user: user, content: 'Bar') }
    before { visit user_path(user) }

    it { should have_content(user.name) }
    it { should have_title(user.name) }

    describe 'the user\'s microposts' do
      it { should have_content(m1.content) }
      it { should have_content(m2.content) }
      it { should have_content(user.microposts.count) }
    end

    describe "follow/unfollow buttons" do
      let(:other_user) { FactoryGirl.create(:user) }
      before { sign_in user }

      describe "following a user" do
        before { visit user_path(other_user) }

        it "should increment the followed user count" do
          expect do
            click_button "Follow"
          end.to change(user.followed_users, :count).by(1)
        end

        it "should increment the other user's followers count" do
          expect do
            click_button "Follow"
          end.to change(other_user.followers, :count).by(1)
        end

        describe "toggling the button" do
          before { click_button "Follow" }
          it { should have_xpath("//input[@value='Unfollow']") }
        end
      end

      describe "unfollowing a user" do
        before do
          user.follow!(other_user)
          visit user_path(other_user)
        end

        it "should decrement the followed user count" do
          expect do
            click_button "Unfollow"
          end.to change(user.followed_users, :count).by(-1)
        end

        it "should decrement the other user's followers count" do
          expect do
            click_button "Unfollow"
          end.to change(other_user.followers, :count).by(-1)
        end

        describe "toggling the button" do
          before { click_button "Unfollow" }
          it { should have_xpath("//input[@value='Follow']") }
        end
      end
    end
  end

  #
  # --- Signup Page---
  #
  describe 'signup page' do
    before { visit signup_path }

    it { should have_content('Sign up') }
    it { should have_title(full_title('Sign up')) }
  end

  describe 'signing up new user' do

    before { visit signup_path }
    let(:submit) { 'Create my account' }

    describe 'with invalid information' do
      it 'should not create a user' do
        expect { click_button submit }.not_to change(User, :count)
      end

      describe 'after submission' do
        before { click_button submit }

        it { should have_title('Sign up') }
        it { should have_content('error') }
      end

    end

    describe 'with valid information' do

      before do
        fill_in 'Name',          with: 'Example User'
        fill_in 'Email',         with: 'user@example.com'
        fill_in 'Password',      with: 'foobar'
        fill_in 'Confirmation',  with: 'foobar'
      end

      it 'should create a valid user' do
        expect { click_button submit }.to change(User, :count).by(1)
      end

      describe 'after saving the user' do
        before { click_button submit }
        let(:user) { User.find_by(email: 'user@example.com') }

        # verify the Welcome flash shows up the first time the user visits profile page
        it { should have_link('Sign out') }
        it { should have_title(user.name) }
        it { should have_selector('div.alert.alert-success', text: 'Welcome') }
      end
    end
  end

  #
  # --- User Edit Page---
  #
  describe 'updating a user' do
    let(:user) { FactoryGirl.create(:user) }
    before do
      sign_in user
      visit edit_user_path(user)
    end

    describe 'the page content' do
      it { should have_content('Update your profile') }
      it { should have_title('Edit User') }
      it { should have_link('change', href: 'http://gravatar.com/emails') }
    end

    describe 'with invalid information' do
      before { click_button 'Save changes' }
      it { should have_content 'error' }
    end

    describe 'with valid information' do
      let(:new_name)  { 'Totes McGee' }
      let(:new_email) { 'daTotes@gmail.com' }

      before do
        fill_in 'Name',          with: new_name
        fill_in 'Email',         with: new_email
        fill_in 'Password',      with: user.password
        fill_in 'Confirmation',  with: user.password
        click_button 'Save changes'
      end

      it { should have_title(new_name) }
      it { should have_selector('div.alert.alert-success') }
      it { should have_link('Sign out', href: signout_path) }

      # "reload" refreshes the 'user' model; we expect it to now
      # have the updated data
      specify { expect(user.reload.name).to eq new_name }
      specify { expect(user.reload.email).to eq new_email.downcase }
    end
  end

  #
  # --- Following / Followers Pages ---
  #
  describe 'following/followers' do
    let(:user) { FactoryGirl.create(:user) }
    let(:other_user) { FactoryGirl.create(:user) }
    before { user.follow!(other_user) }

    describe 'followed users' do
      before do
        sign_in user
        visit following_user_path(user)
      end

      it { should have_title('Following') }
      it { should have_selector('h3', text: 'Following') }
      it { should have_link(other_user.name, href: user_path(other_user)) }
    end

    describe 'followers' do
      before do
        sign_in other_user
        visit followers_user_path(other_user)
      end

      it { should have_title('Followers') }
      it { should have_selector('h3', text: 'Followers') }
      it { should have_link(user.name, href: user_path(user)) }
    end
  end

end
