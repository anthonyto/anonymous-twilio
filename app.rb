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
  
  class Contact
    include Mongoid::Document
    field :sender
    field :receiver
    field :nickname
  end
  
  # Twilio Ruby Gem Credentials
  account_sid   = "AC5e0e37adaf556c3ef136e9ba71536c74"
  auth_token    = "f5ca2a5df3edfbf3c1f81014d11de97b"
  $client       = Twilio::REST::Client.new account_sid, auth_token
  $twilioNumber = "+17606421123" # Anthony's Twilio number

  
  def create_contact(params)
    # do not allow duplicates here
    contact = Contact.new(
      sender: params[:From][2..11],
      receiver: params[:Body].split(" ")[1],
      nickname: params[:Body].split(" ")[2].downcase
    )
    contact.upsert
  end
  
  def send_to_contact(params)
    fromNumber = params[:From][2..11]
    nickname   = params[:Body].split(" ")[0].downcase
    toNumber   = Contact.where(sender: fromNumber, nickname: nickname[1..nickname.length-1]).first[:receiver]
    body       = params[:Body]
    body.slice! /^\S+\s+/
    
    send(toNumber, body)
    save_message(toNumber, fromNumber, body)
  end
  
  def send_to_number(params)
    fromNumber = params[:From][2..11]
    body       = params[:Body]
    toNumber   = body.split(" ")[0]
    body.slice! /^\S+\s+/
    
    send(toNumber, body)
    save_message(toNumber, fromNumber, body)
  end
  
  def respond(params)
    fromNumber = params[:From][2..11]
    body       = params[:Body]
    
    #Find latest message sent to you
    sender = Message.where(to: fromNumber).asc(:time).last
    
    puts "fromNumber #{fromNumber}"
    puts "sender: #{sender}"

    if !sender.nil?
      send(sender[:from], body)
      save_message(sender[:from], fromNumber, body)
    else
      # This person doesn't know what they're doing
      puts "========= BEGIN - RESPONSE FROM SOMEONE WHO DOESN'T KNOW WHAT'S GOING ON ==========="
      puts fromNumber
      puts oldBody
      puts "========= END  -  RESPONSE FROM SOMEONE WHO DOESN'T KNOW WHAT'S GOING ON ==========="
      # return error to sender
    end
  end
  
  def send(toNumber, body)
    # Check to see if the body is just a URL, then send them the image if it is
    if(body =~ URI::regexp)
      # We're working with a URL
      send_mms(toNumber, body)
    else
      # Great, we have a properly formed messaged. Send it
      send_sms(toNumber, body)
    end
  end
  
  def send_mms(toNumber, body)
    $client.account.messages.create(
      :from     => $twilioNumber,
      :to       => toNumber,
      :MediaUrl => body
    )
  end
  
  def send_sms(toNumber, body)
    $client.account.messages.create(
        :from => $twilioNumber,
        :to   => toNumber,
        :body => body
    )
  end
  
  def save_message(toNumber, fromNumber, body)
    Message.create(
        to: toNumber,
        from: fromNumber,
        body: body
    )
  end
  
  
  # GET route at root. Messages sent here will be forwarded to specified 
  # destination number. 
  get '/' do
    
    keyword = params[:Body].split(" ")[0]
    
    # Make method calls based on the first keyword
    if keyword.downcase == "setcontact"
      create_contact(params)
      
    elsif keyword[0] == '#'
      send_to_contact(params)
      
    elsif (keyword.length == 10 && keyword.to_i.to_s == keyword && !params[:Body].empty?) 
      send_to_number(params)
      
    else
      respond(params)
    end
  end
  
end