require 'spec_helper'

MAX_NAME_LENGTH = 50

describe User do

  # set a test user for each test
  before { @user = User.new(name: "Example User", email: "user@example.com") }

  # makes our test user the default subject for our tests
  subject { @user }

  # these tests use the Ruby respond_to? method...good for simple validation
  it { should respond_to(:name) }
  it { should respond_to(:email) }

  # just a sanity check, to ensure our subject is valid
  it { should be_valid }

  # "be_valid" is some rspec magic: any object boolean method will be
  # transcribed into a corresponding test syntax (ex: valid? => be_valid).
  # NOTE: you must use subject { } to create this power
  describe "when name is not present" do
    before { @user.name = " " }
    it { should_not be_valid }
  end

  describe "When email is not present" do
    before { @user.email = " "}
    it { should_not be_valid }
  end

  # 50 is the max length
  describe "when name is too long" do
    before { @user.name = "a" * (MAX_NAME_LENGTH + 1) }
    it { should_not be_valid }
  end

  describe "when email format is valid" do
    it "should be valid" do
      addresses = %w[user@foo.COM A_US-ER@f.b.org frst.lst@foo.jp a+b@baz.cn]
      addresses.each do |valid_address|
        @user.email = valid_address
        expect(@user).to be_valid
      end
    end
  end

  # we need to save a user to test DB to compare it w/ a dupe
  describe "when email address is already taken" do
    before do
      user_with_same_email = @user.dup
      user_with_same_email.email = @user.email.upcase # <- mame case insensitive
      user_with_same_email.save       # <- saves to test DB
    end

    it { should_not be_valid }
  end
end
