class DriveSaveJob < ApplicationJob
  queue_as :default

  def perform(type, user, *args)
    pp "~~~~~~~~~~~~~~~~~~~~~~~~~~"
    pp user
    case type.intern
    when :setting
      obj = args[0]
      google_drive_service(user).setting_save(obj)
    end
  end
  
  private

  def google_drive_service(user)
    @google_drive_service ||= GoogleDriveService.new(user)
    @google_drive_service
  end
end
