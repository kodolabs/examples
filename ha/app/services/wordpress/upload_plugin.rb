class Wordpress::UploadPlugin < Wordpress::Base
  include Ftp::Wrapper

  def call
    update_last_error

    raise I18n.t('notifications.invalid_ftp_connect') unless access_to_ftp?
    connect_to_ftp

    unless folder_exists?(wp_plugin_folder)
      raise I18n.t('notifications.invalid_plugins_folder')
    end

    upload
    remove_tmp_files
    disconnect_from_ftp
    context.host = host
  rescue => e
    update_last_error("FTP: #{e.message}")
    disconnect_from_ftp
    context.fail!(message: e.message)
  end

  private

  def upload
    Zip::File.open(plugin_path) do |zip_file|
      zip_file.each do |entry|
        entry.extract("#{tmp_folder}/#{entry.name}") { true }
        upload_to_server(entry)
      end
    end
  end

  def remove_tmp_files
    FileUtils.rm_rf("#{tmp_folder}/Basic-Auth-master")
  end

  def upload_to_server(entry)
    file_path = "#{wp_plugin_folder}/#{entry.name}"
    if entry.ftype == :directory
      return if folder_exists?(file_path)
      ftp.mkdir(file_path)
    else
      ftp.delete(file_path) if file_exists?(file_path)
      ftp.putbinaryfile(open("#{tmp_folder}/#{entry.name}"), file_path)
    end
  end

  def plugin_path
    Rails.root.join('app', 'plugins', 'Basic-Auth.zip')
  end

  def tmp_folder
    Rails.root.join('tmp')
  end

  def wp_plugin_folder
    "#{host.site_folder}/wp-content/plugins"
  end
end
