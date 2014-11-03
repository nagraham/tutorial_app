require 'spec_helper'

MAX_NAME_LENGTH = 50
MIN_PASSWORD_LEN = 6

describe User do

  # set a test user for each test
  before do
    @user = User.new(name: "Example User", email: "user@example.com",
                     password: "foobar", password_confirmation: "foobar")
  end

  # makes our test user the default subject for our tests
  subject { @user }

  # these tests use the Ruby respond_to? method...good for simple validation
  it { should respond_to(:name) }
  it { should respond_to(:email) }
  it { should respond_to(:password_digest) }
  it { should respond_to(:password) }
  it { should respond_to(:password_confirmation) }
  it { should respond_to(:authenticate) }
  it { should respond_to(:remember_token) }

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

  describe "when password is not present" do
    before do
      @user = User.new(name: "Example User", email: "user@example.com",
                       password: " ", password_confirmation: " ")
    end
    it { should_not be_valid }
  end

  describe "when password doesn't match confirmation password" do
    before { @user.password_confirmation = "mismatch" }
    it { should_not be_valid }
  end

  # the authenticate method is provided by bcrypt-ruby;
  # it is activated by "has_secure_password" method in user model
  describe "return value of password authenticate method " do
    before { @user.save } # <- save to test DB so we can use "find_by()"
    let(:found_user) { User.find_by(email: @user.email) }

    describe "with valid password" do
      it { should eq found_user.authenticate(@user.password) }
    end

    describe "with invalid password" do
      let(:user_for_invalid_password) { found_user.authenticate("invalid") }

      it { should_not eq user_for_invalid_password }
      specify { expect(user_for_invalid_password).to be_false }
    end
  end

  describe "with a password that's too short" do
    before { @user.password = @user.password_confirmation = "a" * (MIN_PASSWORD_LEN - 1)  }
    it { should be_invalid }
  end

  # test for the user's remember token for maintaining sessions
  describe "has valid remember token" do
    before { @user.save }
    its(:remember_token) { should_not be_blank }
  end

end
