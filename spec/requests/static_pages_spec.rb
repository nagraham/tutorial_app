# Integration Test: Static Pages

require 'spec_helper'

describe 'Static pages' do

  # RSPEC: describe block: describe <your test comment> do
  # you can add whatever you want to that string;
  # hopefully something descriptive  . . .
  describe 'Home page' do

    # RSPEC: it <your test comment> do
    it 'should have the content \'Sample App\'' do
      # CAPYBARA is visiting the homepage
      visit '/static_pages/home'
      # CAPYBARA gives us the 'page' variable
      expect(page).to have_content('Sample App')
    end
  end

  describe 'Help page' do
    it 'should have the content \'Help\'' do
      visit '/static_pages/help'
      expect(page).to have_content('Help')
    end
  end

  describe 'About page' do
    it 'should have the content \'About us\'' do
      visit '/static_pages/about'
      expect(page).to have_content('About Us')
    end
  end
end
