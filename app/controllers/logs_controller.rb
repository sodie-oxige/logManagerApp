class LogsController < ApplicationController
  require "nokogiri"

  def index
    @files = list_files.sort { |a, b| b[:date] <=> a[:date] }
  end

  def edit
    pp params
    @file = Logfile.new(
      file_id: params[:id],
      title: params[:title],
      date: params[:date],
      tag: params[:tag],
    )
  end

  def update
    log_params = params.require(:logfile).permit(:date, :title, :tag)
    set = {
      id: params[:id],
      date: log_params[:date],
      title: log_params[:title],
      tag: log_params[:tag]
    }
    render partial: "item", locals: { file: log_params.merge(id: params[:id]).to_h }
    DriveSaveJob.perform_later(:setting, current_user, set)
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
    google_drive_service.list_files_in_folder
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
          comment: p.search("span")[2].inner_html.strip
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
