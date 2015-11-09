class ReplyNotifier < ActionMailer::Base
  include ActionMailerThemer

  def notify_comment_author(theme, reply)
    @comment = reply.comment

    themed_mail(theme: theme,
                to: reply.comment.email,
                sender: email_from(theme),
                from: email_from(theme),
                subject: "#{reply.councillor.display_name.titleize} replied to your message")
  end
end
