class AddCommentsController < ApplicationController
  respond_to :html

  def create
    @application = Application.find(params[:application_id])

    # First check if the honeypot field has been filled out by a spam bot
    # If so, make it look like things worked but don't actually do anything
    if params[:little_sweety].blank?

      @add_comment = AddComment.new(
        add_comment_params.merge(
          application: @application,
          theme: @theme
        )
      )

      @comment = @add_comment.save_comment

      if @comment.nil?
        flash.now[:error] = "Some of the comment wasn't filled out completely. See below."

        if params[:councillors_list_toggler] == "open"
          @councillor_list_open = true
        end

        if writing_to_councillors_enabled?
          @councillors = @application.councillors_for_authority
        end

        # HACK: Required for new email alert signup form
        @alert = Alert.new(address: @application.address)

        render 'applications/show'
      end
    end
  end


  private

  def add_comment_params
    params.require(:add_comment).permit(
      :name,
      :text,
      :address,
      :email,
      :theme,
      :comment_for
    )
  end

  def writing_to_councillors_enabled?
    ENV["COUNCILLORS_ENABLED"] == "true" && @theme == "default"
  end
end
