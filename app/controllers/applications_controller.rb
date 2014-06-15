require 'will_paginate/array'

class ApplicationsController < ApplicationController

  before_filter :check_api_parameters, only: [:api_authority, :api_postcode, :api_suburb,
    :api_point, :api_area, :api_all]

  def check_api_parameters
    valid_parameter_keys = [
      "format", "action", "controller",
      "authority_id",
      "page", "style",
      "postcode",
      "suburb", "state",
      "address", "lat", "lng", "radius", "area_size",
      "bottom_left_lat", "bottom_left_lng", "top_right_lat", "top_right_lng",
      "callback", "count", "v", "key"]

    # Parameter error checking (only do it on the API calls)
    invalid_parameter_keys = params.keys - valid_parameter_keys
    unless invalid_parameter_keys.empty?
      render :text => "Bad request: Invalid parameter(s) used: #{invalid_parameter_keys.sort.join(', ')}", :status => 400
    end
  end

  def per_page
    # Allow to set number of returned applications up to a maximum
    if params[:count] && params[:count].to_i <= Application.per_page
      params[:count].to_i
    else
      Application.per_page
    end
  end

  # TODO don't use instance variables
  def api_render(apps)
    @applications = apps.paginate(:page => params[:page], :per_page => per_page)

    respond_to do |format|
      # TODO: Move the template over to using an xml builder
      format.rss do
        render params[:style] == "html" ? "index_html" : "index",
          :format => :rss, :layout => false, :content_type => Mime::XML
      end
      format.js do
        #ApiStatistic.log(request)
        if params[:v] == "2"
          s = {:applications => @applications, :application_count => @applications.count, :page_count => @applications.total_pages}
        else
          s = @applications
        end
        j = s.to_json(:except => [:authority_id, :suburb, :state, :postcode, :distance],
          :include => {:authority => {:only => [:full_name]}})
        render :json => j, :callback => params[:callback]
      end
    end
  end

  def api_authority
    # TODO Handle the situation where the authority name isn't found
    @authority = Authority.find_by_short_name_encoded!(params[:authority_id])
    @description = "Recent applications from #{@authority.full_name_and_state}"
    api_render(@authority.applications)
  end

  def api_postcode
    # TODO: Check that it's a valid postcode (i.e. numerical and four digits)
    @description = "Recent applications in postcode #{params[:postcode]}"
    api_render(Application.where(:postcode => params[:postcode]))
  end

  def api_suburb
    apps = Application.where(:suburb => params[:suburb])
    @description = "Recent applications in #{params[:suburb]}"
    if params[:state]
      @description += ", #{params[:state]}"
      apps = apps.where(:state => params[:state])
    end
    api_render(apps)
  end

  def api_point
    radius = params[:radius] || params[:area_size] || 2000
    if params[:address]
      location = Location.geocode(params[:address])
      location_text = location.full_address
    else
      location = Location.new(params[:lat].to_f, params[:lng].to_f)
      location_text = location.to_s
    end
    @description = "Recent applications within #{help.meters_in_words(radius.to_i)} of #{location_text}"
    api_render(Application.near([location.lat, location.lng], radius.to_f / 1000, :units => :km))
  end

  def api_area
    lat0, lng0 = params[:bottom_left_lat].to_f, params[:bottom_left_lng].to_f
    lat1, lng1 = params[:top_right_lat].to_f, params[:top_right_lng].to_f
    @description = "Recent applications in the area (#{lat0},#{lng0}) (#{lat1},#{lng1})"
    api_render(Application.where('lat > ? AND lng > ? AND lat < ? AND lng < ?', lat0, lng0, lat1, lng1))
  end

  def api_all
    @description = "Recent applications"

    full = true
    @description << " within the last #{Application.nearby_and_recent_max_age_months} months"
    apps = Application.where("date_scraped > ?", Application.nearby_and_recent_max_age_months.months.ago)

    @applications = apps.paginate(:page => params[:page], :per_page => per_page)

    respond_to do |format|
      # TODO: Move the template over to using an xml builder
      format.rss do
        #ApiStatistic.log(request)
        if !full || ApiKey.where(key: params[:key]).exists?
          render params[:style] == "html" ? "index_html" : "index",
            :format => :rss, :layout => false, :content_type => Mime::XML
        else
          render xml: {error: "not authorised"}, status: 401
        end
      end
      format.js do
        #ApiStatistic.log(request)
        if params[:v] == "2"
          s = {:applications => @applications, :application_count => @applications.count, :page_count => @applications.total_pages}
        else
          s = @applications
        end
        j = s.to_json(:except => [:authority_id, :suburb, :state, :postcode, :distance],
          :include => {:authority => {:only => [:full_name]}})
        if !full || ApiKey.where(key: params[:key]).exists?
          render :json => j, :callback => params[:callback]
        else
          render json: {error: "not authorised"}, status: 401
        end
      end
    end
  end

  def index
    @description = "Recent applications"

    if params[:authority_id]
      # TODO Handle the situation where the authority name isn't found
      @authority = Authority.find_by_short_name_encoded!(params[:authority_id])
      apps = @authority.applications
      @description << " from #{@authority.full_name_and_state}"
    else
      @description << " within the last #{Application.nearby_and_recent_max_age_months} months"
      apps = Application.where("date_scraped > ?", Application.nearby_and_recent_max_age_months.months.ago)
    end

    @applications = apps.paginate(:page => params[:page], :per_page => 30)
  end

  # JSON api for returning the number of scraped applications per day
  def per_day
    authority = Authority.find_by_short_name_encoded!(params[:authority_id])
    respond_to do |format|
      format.js do
        render :json => authority.applications_per_day
      end
    end
  end

  def per_week
    authority = Authority.find_by_short_name_encoded!(params[:authority_id])
    respond_to do |format|
      format.js do
        render :json => authority.applications_per_week
      end
    end
  end

  def address
    @q = params[:q]
    @radius = params[:radius] || 2000
    @sort = params[:sort] || 'time'
    per_page = 30
    if @q
      location = Location.geocode(@q)
      if location.error
        @other_addresses = []
        @error = "Address #{location.error}"
      else
        @q = location.full_address
        @alert = Alert.new(:address => @q)
        @other_addresses = location.all[1..-1].map{|l| l.full_address}
        @applications = case @sort
                        when 'distance'
                          Application.near([location.lat, location.lng], @radius.to_f / 1000, :units => :km).reorder('distance').paginate(:page => params[:page], :per_page => per_page)
                        else # date_scraped
                          Application.near([location.lat, location.lng], @radius.to_f / 1000, :units => :km).paginate(:page => params[:page], :per_page => per_page)
                        end
        @rss = applications_path(:format => 'rss', :address => @q, :radius => @radius)
      end
    end
    @set_focus_control = "q"
    # Use a different template if there are results to display
    if @q && @error.nil?
      render "address_results"
    end
  end

  def search
    # TODO: Fix this hacky ugliness
    if request.format == Mime::HTML
      per_page = 30
    else
      per_page = Application.per_page
    end

    @q = params[:q]
    @applications = Application.search @q, :order => :date_scraped, :sort_mode => :desc, :page => params[:page], :per_page => per_page if @q
    @rss = search_applications_path(:format => "rss", :q => @q, :page => nil) if @q
    @description = @q ? "Search: #{@q}" : "Search"

    respond_to do |format|
      format.html
      format.rss { render "index", :format => :rss, :layout => false, :content_type => Mime::XML }
    end
  end

  def show
    # First check if there is a redirect
    redirect = ApplicationRedirect.find_by_application_id(params[:id])
    if redirect
      redirect_to :id => redirect.redirect_application_id
      return
    end

    @application = Application.find(params[:id])
    @nearby_count = @application.find_all_nearest_or_recent.count
    @comment = Comment.new
    # Required for new email alert signup form
    @alert = Alert.new(:address => @application.address)

    respond_to do |format|
      format.html
    end
  end

  def nearby
    # First check if there is a redirect
    redirect = ApplicationRedirect.find_by_application_id(params[:id])
    if redirect
      redirect_to :id => redirect.redirect_application_id
      return
    end

    @sort = params[:sort]
    @rss = nearby_application_url(params.merge(:format => "rss", :page => nil))

    # TODO: Fix this hacky ugliness
    if request.format == Mime::HTML
      per_page = 30
    else
      per_page = Application.per_page
    end

    @application = Application.find(params[:id])
    case(@sort)
    when "time"
      @applications = @application.find_all_nearest_or_recent.paginate :page => params[:page], :per_page => per_page
    when "distance"
      @applications = Application.unscoped do
        @application.find_all_nearest_or_recent.paginate :page => params[:page], :per_page => per_page
      end
    else
      redirect_to :sort => "time"
      return
    end

    respond_to do |format|
      format.html { render "nearby" }
      format.rss { render "index", :format => :rss, :layout => false, :content_type => Mime::XML }
    end
  end

  private

  def help
    Helper.instance
  end

  class Helper
    include Singleton
    include ApplicationHelper
  end
end
