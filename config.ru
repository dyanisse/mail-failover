require 'sinatra'
require 'grape'
require 'action_mailer'

class UserMailer < ActionMailer::Base
  def sendgrid_email(from, to, subject, body)        
    message = mail(  from: from,
                     to: to,
                     body: body,
                     content_type: "text/html",
                     subject: subject)
    
    message.delivery_method.settings.merge!(
      :smtp_envelope_from => from,
      :user_name => ENV['SENDGRID_USERNAME'],
      :password => ENV['SENDGRID_PASSWORD'],
      :domain => 'yourdomain.com',
      :address => 'smtp.sendgrid.net',
      :port => 587,
      :authentication => :plain,
      :enable_starttls_auto => true)
    
    message
  end
end


class API < Grape::API
  get :hello do
    {hello: "world"}
  end
  
  get :mail do
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
    UserMailer.sendgrid_email("service@daniel.com", "daniel.yanisse@gmail.com", hi, html).deliver
    {email: "sent"}
  end
end

class Web < Sinatra::Base
  get '/' do
    "Hello world."
  end
end

use Rack::Session::Cookie
run Rack::Cascade.new [API, Web]
