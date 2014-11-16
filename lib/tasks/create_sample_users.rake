
# Create 100 fake user accounts
namespace :db do
  desc 'Fill database with sample user data'
  task populate: :environment do

    User.create!(name: 'Faker McGee',
                 email: 'example@example.com',
                 password: 'foobar',
                 password_confirmation: 'foobar',
                 admin: true)

    99.times do |n|
      name = Faker::Name.name
      email = "example-#{n + 1}@example.com"
      password = 'password'
      User.create!(name: name,
                   email: email,
                   password: password,
                   password_confirmation: password)
    end

    users = User.all.limit(6)
    50.times do
      content = Faker::Lorem.sentence(5)
      users.each { |user| user.microposts.create!(content: content) }
    end
  end
end