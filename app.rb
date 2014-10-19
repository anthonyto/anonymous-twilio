require 'rubygems'
require 'sinatra'
require 'twilio-ruby'
require 'json/ext'
require 'mongoid'

# Create new app of type Sinatra
class MyApp < Sinatra::Base
  
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
  
  # GET route at root. Messages sent here will be forwarded to specified 
  # destination number. 
  get '/' do

    fromNumber = params[:From][2..11]
    body       = params[:Body]
    oldBody    = body.dup
    toNumber   = body.split(" ")[0]
    body.slice! /^\S+\s+/


    # Check to see if the number is a 10 digit integer
    puts "==== DIAGNOSING ======"
    puts "toNumber.length #{toNumber.length}"
    puts "toNumber.to_i.to_s == toNumber #{toNumber.to_i.to_s == toNumber}"
    puts "!body.empty? #{!body.empty?}"
    puts "======================"
    if(toNumber.length == 10 && toNumber.to_i.to_s == toNumber && !body.empty?)
      # Check to see if the body is just a URL, then send them the image if it is
      if(body =~ URI::regexp)
        # We're working with a URL
        client.account.messages.create(
          :from     => twilioNumber,
          :to       => toNumber,
          :MediaUrl => body

        )
      else
        # Great, we have a properly formed messaged. Send it
        client.account.messages.create(
          :from => twilioNumber,
          :to   => toNumber,
          :body => body

        )

      end
      # Save message to MongoHQ
      Message.create(
          from: fromNumber,
          to: toNumber,
          body: body
      )
    else
      #Find latest message sent to you
      sender = Message.where(to: fromNumber).asc(:time).last

      puts "sender: #{sender}"

      if !sender.nil?
        #Send the message back
        client.account.messages.create(
            :from => twilioNumber,
            :to   => sender[:from],
            :body => oldBody
        )

        #Store the message transaction
        Message.create(
            to: sender[:from],
            from: fromNumber,
            body: oldBody
        )
      else
        #T his person doesn't know what they're doing
        puts "========= BEGIN - RESPONSE FROM SOMEONE WHO DOESN'T KNOW WHAT'S GOING ON ==========="
        puts fromNumber
        puts oldBody
        puts "========= END  -  RESPONSE FROM SOMEONE WHO DOESN'T KNOW WHAT'S GOING ON ==========="
      end
    end
  end
end
