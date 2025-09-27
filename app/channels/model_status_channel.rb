module ApplicationCable
  class ModelStatusChannel < ApplicationCable::Channel
    def subscribed
      stream_from "model_status_channel"
      stream_from "model_status_channel_#{current_user.id}"
    end

    def unsubscribed
      # Any cleanup needed when channel is unsubscribed
    end
  end
end