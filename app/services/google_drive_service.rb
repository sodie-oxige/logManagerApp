class GoogleDriveService
  require "google/apis/drive_v3"

  def initialize(user)
    user.refresh_access_token
    @service = Google::Apis::DriveV3::DriveService.new
    @service.authorization = user.access_token
    read_or_create_setting_file
  end

  def list_files_in_folder
    read_or_create_setting_file
    query = "'#{@folder.id}' in parents and mimeType = 'text/html'"
    response = @service.list_files(q: query, fields: "files(id, name)")
    response.files.map do |file|
      setting = setting_data[file.id.intern]
      if setting.nil?
        {
          id: file.id,
          date: Date.new(2000, 1, 1),
          title: file.name,
          tag: ""
        }
      else
        {
          id: file.id,
          date: Date.parse(setting[:date]),
          title: setting[:title],
          tag: setting[:tag]
        }
      end
    end
  end

  def file_data(file_id)
    file = @service.get_file(file_id)
    setting = setting_data[file_id.intern]
    if setting.nil?
      {
        id: file_id,
        date: Date.new(2000, 1, 1),
        title: file.name,
        tag: ""
      }
    else
      {
        id: file_id,
        date: Date.parse(setting[:date]),
        title: setting[:title],
        tag: setting[:tag]
      }
    end
  end

  def get_content(file_id, force = false)
    Rails.logger.info("get_content(file_id: #{file_id})")
    download_date = Time.current.strftime("%Y%m%d")
    search_file_path = Dir[Rails.root.join("tmp", "logfile", "*#{file_id}.tmp")].first
    new_file_path = Rails.root.join("tmp", "logfile", "#{download_date}_#{file_id}.tmp")
    if force || search_file_path.blank?
      @service.get_file(file_id, download_dest: new_file_path)
    else
      File.rename(search_file_path, new_file_path)
    end
    if force && search_file_path.present?
    end
    File.read(new_file_path)
  end

  def setting_save(params)
    setting = setting_data
    setting[params[:id]] = params
    @setting[:data] = setting
    file = Google::Apis::DriveV3::File.new(name: "setting.json")
    upload_io = StringIO.new(setting.to_json)
    @service.update_file(@setting[:file].id, file, upload_source: upload_io, content_type: "application/json")
  end

  private

  def read_or_create_folder
    folder_name = "logManagerApp"
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
    @folder
  end

  def read_or_create_setting_file
    read_or_create_folder
    @setting = {} if @setting.nil?
    query = "'#{@folder.id}' in parents and name = 'setting.json' and trashed = false"
    response = @service.list_files(q: query, fields: "files(id, name)")
    if response.files.first.nil?
      file_metadata = Google::Apis::DriveV3::File.new(name: "setting.json", mime_type: "application/json", parents: [ @folder.id ])
      @setting[:data] = {}
      upload_io = StringIO.new(@setting[:data].to_json)
      @setting[:file] = @service.create_file(file_metadata, upload_source: upload_io, content_type: "application/json")
    else
      @setting[:data] = JSON.parse(get_content(response.files.first.id, true), symbolize_names: true)
      @setting[:file] = response.files.first
    end
    @setting
  end

  def setting_data
    read_or_create_setting_file if @setting[:data].nil?
    @setting[:data]
  end
end
