class DeleteOldLogfilesJob < ApplicationJob
  queue_as :default

  def perform
    Rails.logger.info("========== DeleteOldLogfilesJob ==========")
    cutoff_date = 2.day.ago.strftime("%Y%m%d")
    logfiles = Dir[Rails.root.join("tmp", "logfile", "*.tmp")]
    Rails.logger.info("--- logfiles ---")
    Rails.logger.info(logfiles)
    Rails.logger.info("--- delete_logfiles ---")
    logfiles.each do |file_path|
      file_date = File.basename(file_path).split("_").first
      if file_date <= cutoff_date
        Rails.logger.info(file_path)
        File.delete(file_path)
      end
    end
    Rails.logger.info("==========================================")
  end
end
