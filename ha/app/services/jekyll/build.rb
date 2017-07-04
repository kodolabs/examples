class Jekyll::Build < Jekyll::Base
  def call
    update_last_error
    generate_blog
    move_images_to_root_folder
    garbage_collector
  rescue => e
    update_last_error("Build: #{e.message}")
    context.fail!
  end

  private

  def generate_blog
    Jekyll::Commands::Build.process(build_options)
  end

  def move_images_to_root_folder
    return unless Dir.exist?(destination_images_path)

    Find.find(destination_images_path) do |folder|
      next if folder == destination_images_path
      FileUtils.mv(folder, destination_path)
    end
    FileUtils.rm_rf(destination_images_path)
  end

  def garbage_collector
    FileUtils.rm_rf(Rails.root.join('.sass-cache'))
  end

  def build_options
    {
      config: settings_path,
      source: site_path,
      destination: destination_path
    }.stringify_keys
  end
end
