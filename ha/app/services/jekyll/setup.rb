class Jekyll::Setup < Jekyll::Base
  def call
    update_last_error
    clear_site_folder
    create_jekyll_blog
    generate_settings
    install_theme
    create_assets_folders
    garbage_collector
  rescue => e
    update_last_error("Setup: #{e.message}")
    context.fail!
  end

  private

  def create_jekyll_blog
    Jekyll::Commands::New.process([site_path], 'blank' => true)
  end

  def generate_settings
    settings = {
      title: context.host.blog_title,
      description: context.host.description,
      markdown: 'kramdown',
      theme: 'minima',
      permalink: permalink_template,
      gems: ['jekyll-feed']
    }.stringify_keys

    File.open(settings_path, 'w') { |f| f.write settings.to_yaml }
  end

  def install_theme
    Zip::File.open(theme_path) do |zip_file|
      zip_file.each do |entry|
        entry.extract("#{tmp_folder}/#{entry.name}") { true }
        if entry.ftype == :directory
          FileUtils.mkdir_p("#{site_path}/#{entry.name}")
        else
          FileUtils.cp("#{tmp_folder}/#{entry.name}", "#{site_path}/#{entry.name}")
        end
      end
    end
  end

  def create_assets_folders
    FileUtils.mkdir_p(images_path)
  end

  def garbage_collector
    [
      "#{site_path}/__MACOSX",
      "#{site_path}/about.md",
      "#{site_path}/index.html"
    ].each do |path|
      FileUtils.rm_rf(path)
    end
  end

  def theme_path
    Rails.root.join('app', 'plugins', 'minima-theme.zip')
  end

  def tmp_folder
    Rails.root.join('tmp')
  end
end
