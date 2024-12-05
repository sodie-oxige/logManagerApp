class GoogleDriveService
  def initialize(user)
    user.refresh_access_token
    @service = Google::Apis::DriveV3::DriveService.new
    @service.authorization = user.access_token
    @user = user
  end

  def create_file(metadata, fields: nil)
    @service.create_file(metadata, fields: fields)
  end

  def list_files_in_folder(folder_id)
    query = "'#{folder_id}' in parents and trashed=false"
    response = @service.list_files(q: query, fields: "files(id, name, mimeType)")
    response.files.map do |file|
      { id: file.id, name: file.name, mime_type: file.mime_type }
    end
  end
end
