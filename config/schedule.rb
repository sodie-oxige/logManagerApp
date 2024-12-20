# set :environment, "production"
set :output, "log/cron.log"

every 1.days, at: "12:00 am" do
  runner "DeleteOldLogfilesJob.perform_now"
end
