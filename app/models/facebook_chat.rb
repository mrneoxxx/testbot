require 'nlp'
require 'wiki'
require 'messenger_platform/entities/action'
require 'messenger_platform/entities/text_message'
require 'messenger_platform/entities/welcome_button'

module FacebookChat
  extend NLP
  extend self

  def process(params)
    p '============FB PARAMS====================='
    p params
    @params = MessengerPlatform::Parser.execute(params)[0]
    p MessengerPlatform::Parser.execute(params)
    p '============FB PARAMS====================='

    if @params[:type] == 'message'
      MessengerPlatform::Api.call(:action, @params[:from], 'typing_on')
      run_actions(@params[:from], @params[:text])
    elsif @params[:type] == 'payload'
      payload_params = @params[:text].downcase.split('-')
      payload_action = payload_params.delete_at(0)
      if method_defined?(payload_action)
        MessengerPlatform::Api.call(:action, @params[:from], 'typing_on')
        send(payload_action, payload_params)
      end
    end unless @params.blank?
  end

  def proccess_text(text, quickreplies, context_data)
    action = context_data.try(:[], 'process_action')
    if action && method_defined?("send_#{action}")
      send("send_#{action}", text, quickreplies, context_data)
    else
      send_text_message(text, quickreplies)
    end
  end

  def send_text_message(text, quickreplies = nil)
    params = {text: text}
    unless quickreplies.blank?
      params[:quick_replies] = []
      quickreplies.each do |reply|
        params[:quick_replies] << {
          content_type: 'text',
          title: reply,
          payload: 'SENDTEXT'
        }
      end
    end
    MessengerPlatform::Api.call(:text_message, @params[:from], params)
  end

  def send_check_location(text, quickreplies, context_data)
    p '==========send_check_location============='
    p context_data
    if context_data['stations_to'] || context_data['stations_from']
      data = []
      station_direction = (context_data.keys.include?('stations_to') ? 'to' : 'from')
      (context_data['stations_to'] || context_data['stations_from']).each do |station|
        wiki_station_data = Wiki.search(station[:name])
        data << {
          title: text,
          image_url: wiki_station_data.image_urls.select { |ie| !ie.mb_chars.downcase.to_s.include?('.svg') }.first,
          subtitle: wiki_station_data.summary,
          buttons: [{
            type: "postback",
            title: station[:name],
            payload: "SET_STATION-#{station_direction.upcase}-#{station[:code]}"
          }]
        }
      end
      p data
      MessengerPlatform.payload(:generic, @params[:from], data)
    else
      send_text_message(text, quickreplies)
    end
    p '==========send_check_location============='
  end

  def send_search_train(text, quickreplies, context_data)
    data = [{
      title: text,
      image_url: context_data["search_fail"] ? "http://99px.ru/sstorage/53/2015/12/mid_152713_2287.jpg" : "http://malteze.net/images/sampledata/poroda/1v_6453738376545473.jpg",
      buttons: [
        {
          type: 'web_url',
          title: 'Продовжити',
          url: context_data['search_url']
        }
      ]
    }]
    MessengerPlatform.payload(:generic, @params[:from], data)
  end

  def set_station(params)
    get_stations(@params[:from], params[0], params[1])
    run_actions(@params[:from], '', true)
  end

  def change_user_lang(params)
    # update_session(@params[:from], {:context => {'get_hello' => ''}})
    # run_actions(@params[:from], '', true)
    send_text_message('Шукаєш квитки? Я допоможу.')
    MessengerPlatform::Api.call(:action, @params[:from], 'typing_on')
    text = 'Якою мовою тобі зручніше спілкуватися?'
    buttons = [
      {
        type: 'postback',
        title: 'Українська',
        payload: 'SET_USER_LANG-UK'
      }, {
        type: 'postback',
        title: 'Російська',
        payload: 'SET_USER_LANG-RU'
      }
    ]

    MessengerPlatform.payload(:button, @params[:from], text, buttons)
  end

  def set_user_lang(params)
    set_user_data(@params[:from], {locale: params[0].to_sym})
  end
end
