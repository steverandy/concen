Fabricator("control_center/user") do
  username { Fabricate.sequence(:username) { |i| "username#{i}" } }
  full_name { Fabricate.sequence(:full_name) { |i| "Full Name #{i}" } }
  email { Fabricate.sequence(:email) { |i| "user#{i}@mail.com" } }
  password "thisismypassword"
  password_confirmation "thisismypassword"
end

Fabricator("control_center/page") do
  title { Fabricate.sequence(:title) { |i| "Title #{i}" } }
end

