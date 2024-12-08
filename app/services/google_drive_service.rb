class GoogleDriveService
  require "google/apis/drive_v3"

  def initialize(user)
    user.refresh_access_token
    @service = Google::Apis::DriveV3::DriveService.new
    @service.authorization = user.access_token
    @user = user
  rescue => e
    pp "Error: #{e.message}"
    raise
  end

  def create_file(metadata, fields: nil)
    @service.create_file(metadata, fields: fields)
  end

  def list_files_in_folder(folder_id)
    query = "'#{folder_id}' in parents and mimeType = 'text/html'"
    response = @service.list_files(q: query, fields: "files(id, name)")
    response.files.map do |file|
      { id: file.id, name: file.name }
    end
  end

  def get_content(file_id)
    file = @service.get_file(file_id, download_dest: StringIO.new)
    file.string
  end
end
