class ApiController < ApplicationController
  skip_before_filter :set_mobile_format
  skip_before_filter :force_mobile_format
  
  caches_page :howto

  def old_index
    case params[:call]
    when "address"
      redirect_to applications_url(:format => "rss", :address => params[:address], :radius => params[:area_size])
    when "point"
      redirect_to applications_url(:format => "rss", :lat => params[:lat], :lng => params[:lng],
        :radius => params[:area_size])
    when "area"
      redirect_to applications_url(:format => "rss",
        :bottom_left_lat => params[:bottom_left_lat], :bottom_left_lng => params[:bottom_left_lng],
        :top_right_lat => params[:top_right_lat], :top_right_lng => params[:top_right_lng])
    when "authority"
      redirect_to authority_applications_url(:format => "rss", :authority_id => Authority.short_name_encoded(params[:authority]))
    else
      render :text => "unexpected value for parameter call. Accepted values: address, point, area and authority"
    end
  end
  
  def howto
  end  
end
