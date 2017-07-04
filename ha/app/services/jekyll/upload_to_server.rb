class Jekyll::UploadToServer < Jekyll::Base
  include Ftp::Wrapper

  def call
    update_last_error
    raise I18n.t('notifications.invalid_ftp_connect') unless access_to_ftp?
    connect_to_ftp

    unless folder_exists?(host.site_folder)
      raise I18n.t('notifications.invalid_site_folder')
    end

    remove_old_content
    upload_site
    disconnect_from_ftp
  rescue => e
    update_last_error("FTP: #{e.message}")
    disconnect_from_ftp
    context.fail!
  end

  private

  def remove_old_content
    ftp.nlst(host.site_folder).each do |path|
      next unless directory?(path)
      rm_rf(path)
    end
  end

  def upload_site
    index_file_path = ''
    Find.find(destination_path) do |file|
      if file.index('/index.').present?
        index_file_path = file
      else
        upload_to_server(file)
      end
    end
    upload_to_server(index_file_path)
  end

  def upload_to_server(entry)
    site_file_path = entry_path(entry)
    return if site_file_path.blank?

    file_path = "#{host.site_folder}#{site_file_path}"
    if File.directory?(entry)
      return if folder_exists?(file_path)
      ftp.mkdir(file_path)
    else
      ftp.delete(file_path) if file_exists?(file_path)
      ftp.putbinaryfile(open(entry), file_path)
    end
  end

  def entry_path(entry)
    entry.gsub(destination_path, '')
  end
end
