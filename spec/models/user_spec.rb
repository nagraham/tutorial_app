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
  it { should respond_to(:admin) }
  it { should respond_to(:remember_token) }
  it { should respond_to(:microposts) }
  it { should respond_to(:feed) }
  it { should respond_to(:relationships) }
  it { should respond_to(:followed_users) }
  it { should respond_to(:reverse_relationships) }
  it { should respond_to(:followers) }

  # just a sanity check, to ensure our subject is valid
  it { should be_valid }
  it { should_not be_admin }

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

  describe 'with admin attribute set to true' do
    before do
      @user.save!
      @user.toggle!(:admin)
    end

    it { should be_admin }
  end

  #
  # --- Test associations with microposts ---
  #
  describe 'micropost associations' do
    before { @user.save }

    # let!() to override lazy creation, and create immediately
    let!(:older_micropost) do
      FactoryGirl.create(:micropost, user: @user, created_at: 1.day.ago)
    end
    let!(:newer_micropost) do
      FactoryGirl.create(:micropost, user: @user, created_at: 1.hour.ago)
    end

    # convert to array, b/c group of microposts returns as ActiveRecord proxy record
    it 'should have the right microposts in the right order' do
      expect(@user.microposts.to_a).to eql [newer_micropost, older_micropost]
    end

    it 'should destroy associated microposts when the user is destroyed' do
      microposts = @user.microposts.to_a
      @user.destroy
      expect(microposts).not_to be_empty
      microposts.each do |micropost|
        expect(Micropost.where(id: micropost.id)).to be_empty
      end
    end

    describe 'status' do
      let(:unfollowed_user) do
        FactoryGirl.create(:micropost, user: FactoryGirl.create(:user))
      end
      let(:followed_user) { FactoryGirl.create(:user) }
      before do
        @user.follow!(followed_user)
        3.times { followed_user.microposts.create!(content: 'Lorem ipsum') }
      end

      its(:feed) { should include(older_micropost) }
      its(:feed) { should include(newer_micropost) }
      its(:feed) { should_not include(unfollowed_user) }
      its(:feed) do
        followed_user.microposts.each do |micropost|
          should include(micropost)
        end
      end
    end
  end

  #
  # --- Test Following / Being Followed By Users ---
  describe 'following' do
    let(:other_user) { FactoryGirl.create(:user) }
    before do
      @user.save
      @user.follow!(other_user)
    end
    it { should be_following(other_user) }
    its(:followed_users) { should include(other_user) }

    describe 'followed users' do
      subject { other_user }
      its(:followers) { should include(@user) }
    end

    describe 'and unfollowing' do
      before { @user.unfollow!(other_user) }
      it { should_not be_following(other_user) }
      its(:followed_users) { should_not include(other_user) }
    end
  end

end
