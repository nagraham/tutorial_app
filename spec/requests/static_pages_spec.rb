# Integration Test: Static Pages

require 'spec_helper'

describe 'Static pages' do

  # Use the the let(:symbol) function to define variables across all tests
  let(:base_title) { 'Ruby on Rails Tutorial App' }

  # RSPEC: describe block: describe <your test comment> do
  # you can add whatever you want to that string;
  # hopefully something descriptive  . . .
  describe 'Home page' do

    # RSPEC: it <your test comment> do
    it 'should have the content \'Tutorial App\'' do
      # CAPYBARA is visiting the homepage
      visit '/static_pages/home'
      # CAPYBARA gives us the 'page' variable
      expect(page).to have_content('Tutorial App')
    end

    it 'should have the right title' do
      visit '/static_pages/home'
      # don't need full title; you could also use any sub-string
      expect(page).to have_title("#{base_title} | Home")
    end

  end

  describe 'Help page' do
    it 'should have the content \'Help\'' do
      visit '/static_pages/help'
      expect(page).to have_content('Help')
    end

    it 'should have the right title' do
      visit '/static_pages/help'
      expect(page).to have_title("#{base_title} | Help")
    end
  end

  describe 'About page' do
    it 'should have the content \'About Us\'' do
      visit '/static_pages/about'
      expect(page).to have_content('About Us')
    end

    it 'should have the right title' do
      visit '/static_pages/about'
      expect(page).to have_title("#{base_title} | About Us")
    end
  end

  describe 'Contact page' do
    it 'should have the content \'Contact\'' do
      visit '/static_pages/contact'
      expect(page).to have_content('Contact')
    end
  end
end