FactoryGirl.define do

  factory :user do
    sequence(:name)  { |n| "Person #{n}" }
    sequence(:email) { |n| "person_#{n}@example.com" }
    password 'foobar'
    password_confirmation 'foobar'

    # this embedded factor inherits the stuff above!
    factory :admin do
      admin true
    end
  end

  # simply including a user automatically associates a micropost with the user
  factory :micropost do
    content 'Lorem ipsum'
    user
  end

end
