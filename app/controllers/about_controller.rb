class AboutController < ApplicationController
  def index
    @page_title = "About"
    @menu_item = "about"
    
    @authorities = Authority.active.find(:all, :order => "full_name")
      
    @onloadscript = ""
    @set_focus_control = ""
  end
end
