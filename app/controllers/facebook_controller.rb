require "facebook/base"

class FacebookController < ActionController::API
  include Facebook::Base

  def index
    FacebookChat.process(params)
    head :ok
  end

  # def validate
  #   if verify_token_valid? && access_token_valid?
  #     render json: params["hub.challenge"]
  #   elsif !verify_token_valid?
  #     render json: 'Invalid verify token'
  #   else
  #     render json: 'Invalid page access token'
  #   end
  # end
  #
  # def subscribe
  #   render json: activate_bot
  # rescue RestClient::BadRequest
  #   render json: 'Invalid page access token'
  # end
  #
  # private
  #
  # def app_location
  #   "https://graph.facebook.com/v2.6/me/subscribed_apps?access_token=#{Messenger.config.page_access_token}"
  # end
  #
  # def activate_bot
  #   RestClient.post(app_location, nil)
  # end
  #
  # def access_token_valid?
  #   JSON.parse(RestClient.get(app_location)).key?('data')
  # rescue RestClient::BadRequest
  #   return false
  # end
  #
  # def verify_token_valid?
  #   params["hub.verify_token"] == Messenger.config.verify_token
  # end
  #
  # def fb_params
  #   Params.new(params)
  # end

end