class AtdisController < ApplicationController
  def test
    if !params[:url].blank?
      @feed = Feed.create_from_url(params[:url])
      begin
        @page = @feed.applications
      rescue RestClient::InternalServerError => e
        @error = "Remote server returned an internal server error (error code 500) accessing #{params[:url]}"
      rescue RestClient::RequestTimeout => e
        @error = "Timeout in request to #{params[:url]}. Remote server did not respond in a reasonable amount of time."
      rescue RestClient::Exception => e
        @error = "Could not load data - #{e}"
      rescue URI::InvalidURIError => e
        @error = "The url appears to be invalid #{params[:url]}"
      end
    else
      @feed = Feed.new
    end
  end

  # The job here is to take ugly posted parameters and redirect to a much simpler url
  def test_redirect
    @feed = Feed.new(params[:feed])
    if @feed.valid?
      redirect_to atdis_test_url(url: @feed.url)
    else
      render "test"
    end
  end

  def feed
    file = Feed.example_path(params[:number].to_i, (params[:page] || "1").to_i)
    if File.exists?(file)
      render file: file, content_type: Mime::JSON, layout: false
    else
      render text: "not available", status: 404
    end
  end

  def specification
  end

  def guidance
  end
end
