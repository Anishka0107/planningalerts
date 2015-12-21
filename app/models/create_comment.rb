# Comment form object
class CreateComment
  include ActiveModel::Model

  attr_accessor(
    :name,
    :text,
    :address,
    :email,
    :theme,
    :comment_for,
    :application_id
  )

  validates_presence_of :name, :text, :email
  validates_presence_of :address, unless: :for_councillor?
  validates_email_format_of :email
  validates_presence_of(
    :comment_for,
    if: :has_for_options?,
    message: "You need to select who your message should go to from the list below."
  )

  def save_comment
    if valid?
      remove_address_if_for_councillor

      @comment = Comment.new(
        application_id: application_id,
        name: name,
        text: text,
        address: address,
        email: email,
        theme: theme
      )

      process_comment_for(@comment)

      @comment if @comment.save
    end
  end

  def has_for_options?
    if ENV["COUNCILLORS_ENABLED"] == "true" && theme == "default"
      Application.find(application_id).authority.councillors.any?
    else
      false
    end
  end

  def for_planning_authority?
    comment_for.nil? || comment_for == "planning authority"
  end

  def for_councillor?
    !for_planning_authority?
  end

  def remove_address_if_for_councillor
    self.address = nil if for_councillor?
  end

  private

  def process_comment_for(comment)
    if comment_for.present? && comment_for != "planning authority"
      comment.councillor_id = Councillor.find(comment_for).id
    end
  end
end
