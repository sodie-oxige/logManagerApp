class LogsController < ApplicationController
  require "rest-client"

  def index
    @files = list_files
  end

  def show
    @id = params[:id]
  end

  private

  def list_files
    folder_id = current_user.google_drive_folder_id
    if folder_id.blank?
      folder_id = create_drive_folder("logManagerApp")
      current_user.update(google_drive_folder_id: folder_id)
    end

    drive_service = GoogleDriveService.new(current_user)
    files = drive_service.list_files_in_folder(folder_id)
    files
  rescue => e
    pp "Error: #{e.message}"
    []
  end


  def create_drive_folder(folder_name)
    service = GoogleDriveService.new(current_user)

    metadata = Google::Apis::DriveV3::File.new(
      name: folder_name,
      mime_type: "application/vnd.google-apps.folder"
    )
    folder = service.create_file(metadata, fields: "id")
    folder.id
  rescue => e
    Rails.logger.error("Failed to create folder: #{e.message}")
  end
end
