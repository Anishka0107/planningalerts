class StandaloneSweeper < ActionController::Caching::Sweeper
  include ActionController::UrlWriter

  protected
  
  # Providing my own implementation of expire_page because we don't have a controller set when this sweeper is
  # used from a rake task
  def expire_page(options)
    if options[:action].is_a?(Array)
      options[:action].each do |action|
        ActionController::Base.expire_page(url_for options.merge(:only_path => true, :skip_relative_url_root => true, :action => action))
      end
    else
      ActionController::Base.expire_page(url_for options.merge(:only_path => true, :skip_relative_url_root => true))
    end
  end
end

