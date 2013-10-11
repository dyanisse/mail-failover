require 'sinatra'
require 'grape'
require 'action_mailer'

configure do
  ActionMailer::Base.smtp_settings = {
    port: 587,
    authentication: :plain,
    enable_starttls_auto: true,
    return_response: true}
end

class UserMailer < ActionMailer::Base  
  def base_email(from, to, subject, body)
    mail(  from: from,
           to: to,
           body: body,
           content_type: "text/html",
           subject: subject)
  end
  
  def sendgrid_email(from, to, subject, body)
    message = base_email(from, to, subject, body)
    message.delivery_method.settings.merge!(
      :smtp_envelope_from => from,
      :user_name => "",
      :password => "",
      :domain => 'yourdomain.com',
      :address => 'smtp.sendgrid.net')
  end
  
  def mandrill_email(from, to, subject, body)        
    message = base_email(from, to, subject, body) 
    message.delivery_method.settings.merge!(
      :smtp_envelope_from => from,
      :user_name => "",
      :password => "",
      :domain => 'yourdomain.com',
      :address => 'smtp.mandrillapp.com')
  end
end


class API < Grape::API
  post :email do
    html = %(
    <!DOCTYPE html>
    <html>
      <head>
        <meta content='text/html; charset=UTF-8' http-equiv='Content-Type' />
      </head>
      <body>
        <h1>Welcome to example.com, <%= @user.name %></h1>
        <p>
          You have successfully signed up to example.com,
          your username is: <%= @user.login %>.<br/>
        </p>
        <p>
          To login to the site, just follow this link: <%= @url %>.
        </p>
        <p>Thanks for joining and have a great day!</p>
      </body>
    </html>)
    response = UserMailer.sendgrid_email("service@daniel.com", "daniel.yanisse@gmail.com", "hi", html).deliver!
    # sendrgid: @status="250", @string="250 Delivery in progress\n"
    # mandrill: @status="250", @string="250 2.0.0 Ok: queued as 0400D3A050E\n"
    {email: "sent"}
  end
end

use Rack::Session::Cookie
run Rack::Cascade.new [API]
