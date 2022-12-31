defmodule Newnix.Providers do
  @providers [
    {:mailjet, "Mailjet"},
    {:postmark, "Postmark"},
    {:sparkpost, "SparkPost"},
    {:mailchimp, "Mailchimp"},
    {:mailgun, "Mailgun"},
    {:sendgrid, "SendGrid"},
    {:sendinblue, "SendinBlue"},
    {:mailpace, "MailPace"},
    {:socketlabs, "SocketLabs"},
    {:gmail, "Gmail"}
  ]

  def get_active_prodivders() do
    @providers
  end
end
