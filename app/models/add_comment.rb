# Comment form object
class AddComment
  include ActiveModel::Model

  attr_accessor(
    :name,
    :text,
    :address,
    :email,
    :theme,
    :comment_for,
    :application
  )

  validates_presence_of :name, :text, :email
  validates_presence_of :address, unless: :for_councillor?
  validates_email_format_of :email
  validates_presence_of(
    :comment_for,
    if: :could_be_for_councillor?,
    message: "You need to select who your message should go to from the list below."
  )

  def save_comment
    if valid?
      remove_address_if_for_councillor

      @comment = Comment.new(
        application_id: application.id,
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

  def could_be_for_councillor?
    application.councillors_available_for_contact && theme.eql?("default") ?  true : false
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
    comment.councillor_id = Councillor.find(comment_for).id if for_councillor?
  end
end
