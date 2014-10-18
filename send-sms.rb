require 'rubygems'
require 'sinatra'
require 'twilio-ruby'
require 'mongo'
require 'json/ext'

include Mongo

configure do
  conn = MongoClient.new("mongodb://anon:anonymous@linus.mongohq.com:10077/anonymous_twillio")
  set :mongo_connection, conn
  # set :mongo_db, conn.db('anonymous_twillio')
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

put settings.mongo_db["sms"].find.to_a.to_json
#
# get '/sms-sent' do
#   sender = params[:From]
#   puts params
#
#   twiml = Twill
# end