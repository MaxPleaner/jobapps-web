class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
#   protect_from_forgery with: :exception
#   http_basic_authenticate_with(name: ENV["HTTP_USERNAME"], password: ENV["HTTP_PASSWORD"])

  before_action :set_flash_messages
  def set_flash_messages
    flash[:messages] ||= []
  end

  before_action :store_session_in_thread
  def store_session_in_thread
    Thread.current[:session] = session
  end


  def set_current_page(page)
    {
      only_todos: page.eql?("only_todos"),
      no_filter: page.eql?("no_filter"),
      most_recent_skips: page.eql?("most_recent_skips"),
      starred: page.eql?("starred")
    }.each do |k, v|
      session[k.to_s] = v
    end
  end

  # Using Thread.current to access session from models
  # It's used for dynamic scoping on models
  # i.e. preferences for which records are returned
  def session=(key, val)
    res = super(key, val)
    Thread.current[:session] = res
  end

end
