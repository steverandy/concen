# set :output, "log/cron.log"
# 
# every 1.hour, :at => 1 do
#   rake "control_center:visit_statistic:hourly_unique_visit"
#   rake "control_center:visit_statistic:hourly_location"
# end
# 
# every 1.day, :at => "0:01am" do
#   rake "control_center:visit_statistic:daily_unique_visit"
# end
# 
# every 1.month, :at => "start of the month at 1am" do
#   rake "control_center:visit_statistic:monthly_unique_visit"
#   rake "control_center:visit_statistic:monthly_referrer"
#   rake "control_center:visit_statistic:monthly_resolution"
#   rake "control_center:visit_statistic:monthly_browser"
#   rake "control_center:visit_statistic:monthly_operating_system"
#   rake "control_center:visit_statistic:monthly_location"
#   # rake "control_center:visit_statistic:wipe_visit"
# end
