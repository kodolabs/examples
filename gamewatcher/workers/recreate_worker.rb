class RecreateWorker
  include Sidekiq::Worker

  def perform(model_name, id, uploader_name)
    begin
      klass = model_name.to_s.classify.constantize
      object = klass.find(id)
      uploader = object.send(uploader_name.to_sym)
      uploader.cache_stored_file!
      uploader.retrieve_from_cache!(uploader.cache_name)
      uploader.recreate_versions!
    rescue => e
      puts "Error: #{e}"
    end
  end
end
