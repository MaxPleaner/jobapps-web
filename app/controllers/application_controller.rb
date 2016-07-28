class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
#   protect_from_forgery with: :exception
#   http_basic_authenticate_with(name: ENV["HTTP_USERNAME"], password: ENV["HTTP_PASSWORD"])

  before_action :set_flash_messages
  def set_flash_messages
    flash[:messages] ||= []
  end

  def set_autoscroll
    case generic_params[:autoscroll]
    when "on"
      session["autoscroll"] = true
    when "off"
      session["autoscroll"] = false
    end
  end

  before_action :store_session_in_thread
  def store_session_in_thread
    Thread.current[:session] = session
  end

  def define_current_company
    filter = generic_params[:filter]
    is_new_company = filter == 'new_company'
    is_company_show_page = !!generic_params[:id]
    is_no_filter = !!session["no_filter"]
    is_starred_filter = !!session["starred"]
    is_todos_filter = !!session["only_todos"]
    is_skips_filter = !!session["most_recent_skips"]
   if is_new_company
      @company = Company.new(flash["company"]) || Company.new
   elsif is_company_show_page
      @company = Company.unscoped.find(generic_params[:id])
   elsif is_no_filter
      if params[:random]
        @company = Company.sample
      else
        @company = Company.first
      end
   elsif is_starred_filter
      @company = Company.unscoped.where(starred: true).first
   elsif is_todos_filter
      @company = Company.todo.limit(1).first || switch_to_no_filter
   elsif is_skips_filter
      @most_recent_skips = Company.skipped.last(@most_recent_skip_count)
   else
      @company = Company.blank.limit(1).first || switch_to_no_filter
    end
    @company ||= Company.new
  end

  def switch_to_no_filter
    Company.first.tap do
      set_current_page_in_session("no_filter")
      flash[:messages] << "No more blanks. Switching to no filter."
    end
  end

  def add_company
    @company&.update(company_params)
    @company ||= Company.create(company_params)
    if @company.persisted?
      @category = Category.find_or_create_by(name: @company.category)
    else
      @company.errors.full_messages.each { |err| flash[:messages] << err}
    end
  end

  def set_category
    if @company.update(category: generic_params[:update_value])
      @category = Category.find_or_create_by(name: @company.category)
    else
      @company.errors.full_messages.each { |err| flash[:messages] << err}
    end
  end

  def set_recently_edited_companies
    recently_edited_companies = session["recently_edited_companies"] || []
    recently_edited_companies.reject! { |company| company["id"].eql?(@company.id) }
    recently_edited_companies << @company.status.merge( "id" => @company.id )
    recently_edited_companies.shift if recently_edited_companies.length > 5
    session["recently_edited_companies"] = recently_edited_companies
  end

  def set_current_page
    case generic_params[:filter]
    when "only_todos"
      set_current_page_in_session("only_todos")
    when "no_filter"
      set_current_page_in_session("no_filter")
    when "not_only_todos"
      set_current_page_in_session("none")
    when "starred"
      set_current_page_in_session("starred")
    when "most_recent_skips"
      set_current_page_in_session("most_recent_skips")
      session["most_recent_skip_count"] =\
      @most_recent_skip_count = generic_params[:most_recent_skip_count] ||\
                                session["most_recent_skip_count"] ||\
                                5
    end
  end

  def set_current_page_in_session(page)
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
