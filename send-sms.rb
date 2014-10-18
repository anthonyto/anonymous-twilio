require 'rubygems'
require 'sinatra'
require 'twilio-ruby'
require 'mongo'
# require 'json/ext'
require 'mongoid'

include Mongo

configure do
  Mongoid.load!('mongoid.yml')
end

# Credentials
account_sid = "AC5e0e37adaf556c3ef136e9ba71536c74"
auth_token  = "f5ca2a5df3edfbf3c1f81014d11de97b"
client      = Twilio::REST::Client.new account_sid, auth_token
from        = "+17606421123" # Your Twilio number

 
friends = {
"+18582295512" => "Anthony",
"+17155737579" => "Alex",
"+17159372022" => "Nick"
}


# friends.each do |key, value|
#   client.account.messages.create(
#     :from => from,
#     :to => key,
#     :body => "Hey #{value}, Monkey party at 6PM. Bring Bananas!"
#   )
#   puts "Sent message to #{value}"
# end

#Creat new app of type Sinatra
class MyApp < Sinatra::Base

  # Twilio Ruby Gem Credentials
  account_sid = "AC5e0e37adaf556c3ef136e9ba71536c74"
  auth_token  = "f5ca2a5df3edfbf3c1f81014d11de97b"
  client      = Twilio::REST::Client.new account_sid, auth_token
  from        = "+17606421123" # Anthony's Twilio number

  friends = {
      "+18582295512" => "Anthony",
      "+17155737579" => "Alex",
      "+17159372022" => "Nick"
  }

  friendsNames = {
      "Anthony" => "+18582295512",
      "Alex" => "+17155737579",
      "Nick" => "+17159372022"
  }
  
  get '/' do
    # puts params

    fromNumber = params[:From]
    body = params[:Body]

    puts body
    puts fromNumber

    toNumber = body.split(" ")[0]
    body.slice! /^\S+\s+/


    puts toNumber
    puts body

    client.account.messages.create(
        :from => from,
        :to => toNumber,
        :body => body
    )


  end
  
end
