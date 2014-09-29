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

  describe 'Home page' do

    before { visit root_path }  # specify which path CAPYBARA should visit
    it { should have_content('Tutorial App') }
    it { should have_title(full_title('')) }
    # We test that it DOESN'T have the page title because have_title
    # will also just search for sub-strings
    it { should_not have_title('| Home') }

  end

  describe 'Help page' do
    before { visit help_path }
    it { should have_content('Help') }
    it { should have_title (full_title('Help'))}
  end

  describe 'About page' do
    before { visit about_path }
    it { should have_content('About Us') }
    it { should have_title(full_title('About Us')) }
  end

  describe 'Contact page' do
    before { visit contact_path }
    it { should have_content('Contact')}
    it { should have_title(full_title('Contact'))}
  end
end