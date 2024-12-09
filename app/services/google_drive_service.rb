class GoogleDriveService
  require "google/apis/drive_v3"

  def initialize(user)
    folder_name = "logManagerApp"

    user.refresh_access_token
    @service = Google::Apis::DriveV3::DriveService.new
    @service.authorization = user.access_token

    query = "name = '#{folder_name}' and mimeType = 'application/vnd.google-apps.folder'"
    response = @service.list_files(q: query)
    if response.files.empty?
      metadata = {
        name: folder_name,
        mime_type: "application/vnd.google-apps.folder"
      }
      @folder = @service.create_file(metadata, fields: "id, name")
    else
      @folder = response.files.first
    end
  end

  def list_files_in_folder
    query = "'#{@folder.id}' in parents and mimeType = 'text/html'"
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
