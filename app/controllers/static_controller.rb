# Controller for (mostly) static content
class StaticController < ApplicationController
  # Reinstate caching of faq page when all authorities have commenting feature
  #caches_page :about, :faq, :get_involved
  # Don't cache about page because we randomly rearrange the list of contributors on each request
  caches_page :get_involved, :how_to_write_a_scraper, :how_to_lobby_your_local_authority

  def about
  end
  
  def faq
    @comment = params[:comment]
  end
  
  def get_involved
  end

  def how_to_write_a_scraper
  end

  def how_to_lobby_your_local_authority
  end

  def error_404
    render :status => :not_found
  end
end
