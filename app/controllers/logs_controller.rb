class LogsController < ApplicationController
  require "nokogiri"

  def index
    @files = list_files
  end

  def show
    @contents = get_logcontent(params[:id])
  end

  private

  def google_drive_service
    @google_drive_service ||= GoogleDriveService.new(current_user)
    @google_drive_service
  end

  def list_files
    folder_id = current_user.google_drive_folder_id
    if folder_id.blank?
      folder_id = create_drive_folder("logManagerApp")
      current_user.update(google_drive_folder_id: folder_id)
    end

    files = google_drive_service.list_files_in_folder(folder_id)
    files
  rescue => e
    pp "Error: #{e.message}"
    []
  end

  def create_drive_folder(folder_name)
    metadata = Google::Apis::DriveV3::File.new(
      name: folder_name,
      mime_type: "application/vnd.google-apps.folder"
    )
    folder = google_drive_service.create_file(metadata, fields: "id")
    folder.id
  rescue => e
    Rails.logger.error("Failed to create folder: #{e.message}")
  end

  def get_logcontent(id, index = 0)
    if @logcontent.present? && @logcontent[:id] == id
    else
      doc = Nokogiri::HTML(google_drive_service.get_content(id))
      content_data = doc.css("p").map do |p|
        {
          color: p[:style].strip.match(/color:(#[\da-f]+);/)[1],
          tab: p.search("span")[0].text.strip.match(/\[(.+)\]/)[1],
          author: p.search("span")[1].text.strip,
          comment: p.search("span")[2].text.strip
        }
      end
      @logcontent = {
        id: id,
        data: content_data
      }
    end
    # @logcontent[:data][index..index+20]
    @logcontent[:data]
  end
end
