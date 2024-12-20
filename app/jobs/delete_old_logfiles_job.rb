class DeleteOldLogfilesJob < ApplicationJob
  queue_as :default

  def perform(*args)
    cutoff_date = 1.day.ago.strftime("%Y%m%d")

    Dir[Rails.root.join("temp/logfile/*.tmp")].each do |file_path|
      file_date = File.basename(file_path).split("_").first

      if file_date <= cutoff_date
        File.delete(file_path)
      end
    end
  end
end
