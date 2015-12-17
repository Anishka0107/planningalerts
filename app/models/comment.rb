class Comment < ActiveRecord::Base
  belongs_to :application
  belongs_to :councillor
  has_many :reports
  has_many :replies
  validates_presence_of :name, :text, :address
  validate :receiver_must_be_selected_if_options_available

  attr_accessor :for_planning_authority

  acts_as_email_confirmable
  scope :visible, -> { where(confirmed: true, hidden: false) }
  scope :in_past_week, -> { where("created_at > ?", 7.days.ago) }

  scope :visible_with_unique_emails_for_date, ->(date) {
    visible.where("date(created_at) = ?", date).group(:email)
  }

  scope :by_first_time_commenters_for_date, ->(date) {
    visible_with_unique_emails_for_date(date)
    .select {|c| where("email = ? AND created_at < ?", c.email, c.created_at.to_date).empty? }
  }

  scope :by_returning_commenters_for_date, ->(date) {
    visible_with_unique_emails_for_date(date)
    .select {|c| where("email = ? AND created_at < ?", c.email, c.created_at.to_date).any? }
  }

  # Send the comment to the planning authority
  def after_confirm
    if to_councillor?
      CommentNotifier.delay.notify_councillor("default", self)
    else
      CommentNotifier.delay.notify_authority("default", self)
    end
  end

  def has_receiver_options?
    if ENV["COUNCILLORS_ENABLED"] == "true" && theme == "default"
      application.authority.councillors.any?
    else
      false
    end
  end

  def for_planning_authority?
    if for_planning_authority.present?
      for_planning_authority
    else
      !has_receiver_options?
    end
  end

  def to_councillor?
    councillor ? true : false
  end

  def awaiting_councillor_reply?
    to_councillor? && replies.empty?
  end

  def recipient_display_name
    to_councillor? ? councillor.prefixed_name : application.authority.full_name
  end

  private

  def receiver_must_be_selected_if_options_available
    if has_receiver_options?
     if for_planning_authority.blank? && councillor_id.nil?
       errors.add(
         :receiver_options,
         "You need to select who your message should go to from the list below."
       )
     end
    end
  end
end
