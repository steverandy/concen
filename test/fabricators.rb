Fabricator("control_center/page") do
  title { Fabricate.sequence(:title) { |i| "Title #{i}" } }
  # password "password"
  # password_confirmation "password"
end
