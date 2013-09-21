require 'rubygems'
require 'sinatra'
require 'constants'
require 'rest-client'
require 'json'

enable :sessions

set :session_secret, APP_SECRET

get '/' do
    if session['venmo_token']
        'Your Venmo token is %s' % session[:venmo_token]
    else
        redirect to('https://api.venmo.com/oauth/authorize?client_id=%s&scope=make_payments,access_profile&response_type=code' % CONSUMER_ID)
    end
end

get '/oauth-authorized' do
    AUTHORIZATION_CODE = request['code']
    data = {
        "client_id"=>CONSUMER_ID,
        "client_secret"=>CONSUMER_SECRET,
        "code"=>AUTHORIZATION_CODE
        }
    url = "https://api.venmo.com/oauth/access_token"
    response = RestClient.post 'https://api.venmo.com/oauth/access_token', data
    response_dict = JSON.parse(response.to_str)

    access_token = response_dict['access_token']
    user = response_dict['user']

    session['venmo_token'] = access_token
    session['venmo_username'] = user['username']

    'You were signed in as %s' % user['username']

end
