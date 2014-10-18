require 'rubygems'
require 'sinatra'
require 'twilio-ruby'
# require 'mongo'
require 'json/ext'
require 'mongoid'

# Create new app of type Sinatra
class MyApp < Sinatra::Base
  
  #### CONFIGURATION ####
  # Load mongoHQ credentials from the mongoid.yml file
  Mongoid.load!("mongoid.yml")
  
  # Create MongoDB collection
  class Message
    include Mongoid::Document
    field :from
    field :to
    field :body
    field :time, type: Time, default: ->{ Time.now }
  end
  
  # Twilio Ruby Gem Credentials
  account_sid  = "AC5e0e37adaf556c3ef136e9ba71536c74"
  auth_token   = "f5ca2a5df3edfbf3c1f81014d11de97b"
  client       = Twilio::REST::Client.new account_sid, auth_token
  twilioNumber = "+17606421123" # Anthony's Twilio number
  
  #### ROUTE ####
  get '/' do

    fromNumber = params[:From]
    body = params[:Body]

    puts "========= BEGIN - RESPONSE FROM SOMEONE WHO DOESN'T KNOW WHAT'S GOING ON ==========="
    puts fromNumber
    puts body
    puts "========= END  -  RESPONSE FROM SOMEONE WHO DOESN'T KNOW WHAT'S GOING ON ==========="


    toNumber = body.split(" ")[0]
    body.slice! /^\S+\s+/


    puts toNumber
    puts body
 
    Message.create(
      from: fromNumber,
      to: toNumber,
      body: body
    )
    
    client.account.messages.create(
        :from => twilioNumber,
        :to => toNumber,
        :body => body
    )
  end
end
