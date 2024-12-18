class DriveSaveJob < ApplicationJob
  queue_as :default

  def perform(type, user, *args)
    case type.intern
    when :setting
      obj = args[0]
      google_drive_service(user).setting_save(obj)
    end
    Rails.logger.info("Job finished: job_id=#{self.job_id}, type=#{type}, user_id=#{user.id}")
  end

  private

  def google_drive_service(user)
    @google_drive_service ||= GoogleDriveService.new(user)
    @google_drive_service
  end
end
