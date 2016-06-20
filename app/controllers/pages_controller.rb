class PagesController < ApplicationController

  def get_indeed_listings
    Category.find_or_create_by(name: "indeed")
    0.upto(7).to_a.each do |i| # get 7 pages
      FindJobListings::Indeed_API.new.jobs(
        start: 25 * i, limit: 25, search_term: 'software'
      ).each do |company|
        Company.create(
          name: company[:company],
          desc: company[:location] + " - " + company[:description] + " - " + company[:url],
          jobs: company[:jobtitle],
          category: "indeed"
        )
      end
    end
    redirect_to :back
  end

  def add_yaml_list
    # renders a form
  end

  def save_yaml_list
    @yaml = params[:yaml]
    @category = params[:category]
    Category.find_or_create_by(name: @category)
    if @yaml && @category
      companies = YAML.load(@yaml).map do |attrs|
        Company.create(attrs.merge("category" => @category))
      end
      created_count = 0
      companies.each do |company|
        errors = company.errors.full_messages
        if errors.any?
          flash[:messages] << "error creating #{company.name} - #{errors}"
        else
          created_count += 1
        end
        flash[:messages] << "Created #{created_count} companies from YAML"
      end
    end
    redirect_to "/"
  end

  def get_stackoverflow_listings
    Category.find_or_create_by(name: "stackoverflow")
    FindJobListings::StackOverflow_API.new.jobs(
      start: (0), limit: 50, search_term: 'software'
    )&.each do |company|
      company = Company.create(
        name: company[:title],
        desc: company[:description] + " - " + company[:location],
        jobs: company[:link],
        category: "stackoverflow"
      )
    end
    redirect_to :back
  end

  def root
    if generic_params[:autoscroll] == "on"
      session["autoscroll"] = true
    elsif generic_params[:autoscroll] == "off"
      session["autoscroll"] = false
    end
    filter = generic_params[:filter]
    if filter && filter.eql?("only_todos")
      set_current_page("only_todos")
    elsif filter && filter.eql?("no_filter")
      set_current_page("no_filter")
    elsif filter && filter.eql?("not_only_todos")
      set_current_page("none")
    elsif filter && filter.eql?("most_recent_skips")
      set_current_page("most_recent_skips")
      @most_recent_skip_count = generic_params[:most_recent_skip_count] || session["most_recent_skip_count"] || 5
      session["most_recent_skip_count"] = @most_recent_skip_count
    elsif filter && filter.eql?("starred")
      set_current_page("starred")
    end
    @most_recent_skip_count = session["most_recent_skip_count"] || 5
    @percentage_completed = "#{((Company.nonblank.count.to_f / Company.count.to_f) * 100.to_f).round(2)}%"
    @todos_count = Company.todo.count
    @application_count = Company.applied.count
    @skipped_count = Company.skipped.count
    if generic_params[:filter] && generic_params[:filter].eql?("new_company")
      @company = Company.new(flash["company"]) || Company.new
    elsif generic_params[:id]
      @company = Company.unscoped.find(generic_params[:id])
    else
      if session["no_filter"]
        @company = Company.first
      elsif session["starred"]
        @company = Company.unscoped.where(starred: true).first
      elsif session["only_todos"]
        @company = Company.todo.limit(1).first
        unless @company
          @company = Company.first
          set_current_page("no_filter")
          flash[:messages] << "No more todos. Switching to no filter"
        end
      elsif session["most_recent_skips"]
        @most_recent_skips = Company.skipped.last(@most_recent_skip_count)
      else
        @company = Company.blank.limit(1).first
        unless @company
          @company = Company.first
          set_current_page("no_filter")
          flash[:messages] << "No more blanks. Switching to no filter."
        end
      end
    end
    @company ||= Company.new
  end

  def category_toggler
    @categories = Category.all.order(id: :desc)
    if generic_params[:cmd] && generic_params[:cmd].eql?("toggle")
      @category = Category.find_by(id: generic_params[:category_id])
      unless @category.update(hidden: !@category.hidden)
      redirect_to "/category_toggler"
    else
      render "category_toggler"
    end
  end

  def search
    flash[:search_results] = Company.search(params[:query])
    redirect_to "/"
  end

  def update
    @company = Company.unscoped.find_by(id: generic_params[:id])
    cmd = generic_params[:cmd]
    case cmd
    when "add_company"
      add_company = true
      @company&.update(company_params)
      @company ||= Company.create(company_params)
      if @company.persisted?
        @category = Category.find_or_create_by(name: @company.category)
      else
        @company.errors.full_messages.each { |err| flash[:messages] << err}
      end
    when "set_category"
      if @company.update(category: generic_params[:update_value])
        @category = Category.find_or_create_by(name: @company.category)
      else
        @company.errors.full_messages.each { |err| flash[:messages] << err}
      end
    when "quick_skip"
      unless @company.update(skip: "true", todo: nil)
        @company.errors.full_messages.each { |err| flash[:messages] << err}
      end
    when "quick_apply"
      unless @company.update(applied: "true", todo: nil)
        @company.errors.full_messages.each { |err| flash[:messages] << err}
      end
    when "quick_todo"
      unless @company.update(todo: "true")
        @company.errors.full_messages.each { |err| flash[:messages] << err}
      end
    when "quick_rejected"
      unless @company.update(rejected: "true", todo: nil)
        @company.errors.full_messages.each { |err| flash[:messages] << err}
      end
    when "skip_with_note"
      unless @company.update(skip: generic_params[:update_value], todo: nil)
        @company.errors.full_messages.each { |err| flash[:messages] << err}
      end
    when "apply_with_note"
      unless @company.update(applied: generic_params[:update_value], todo: nil)
        @company.errors.full_messages.each { |err| flash[:messages] << err}
      end
    when "todo_with_note"
      unless @company.update(todo: generic_params[:update_value])
        @company.errors.full_messages.each { |err| flash[:messages] << err}
      end
    when "not_laughing"
      unless @company.update(notlaughing: generic_params[:update_value])
        @company.errors.full_messages.each { |err| flash[:messages] << err}
      end
    when "undo_todo"
      unless @company.update(todo: nil)
        @company.errors.full_messages.each { |err| flash[:messages] << err}
      end
    when "undo_skip"
      unless @company.update(skip: nil)
        @company.errors.full_messages.each { |err| flash[:messages] << err}
      end
    when "star"
      unless @company.update(starred: true)
        @company.errors.full_messages.each { |err| flash[:messages] << err}
      end
    when "unstar"
      unless @company.update(starred: false)
        @company.errors.full_messages.each { |err| flash[:messages] << err}
      end
    when "undo_apply"
      unless @company.update(applied: false)
        @company.errors.full_messages.each { |err| flash[:messages] << err}
      end
    end
    if @company.persisted?
      session["recently_edited_companies"] ||= []
      session["recently_edited_companies"] = session["recently_edited_companies"].reject { |company|
          company["id"].eql?(@company.id)
      }
      session["recently_edited_companies"] << @company.status.merge(
        "id" => @company.id
      )
      session["recently_edited_companies"] = session["recently_edited_companies"][1..-1] if session["recently_edited_companies"].length > 5
    end
    if add_company
      if @company.persisted?
        redirect_to "/?id=#{@company.id}"
      else
        @company.errors.full_messages.each { |err| flash[:messages] << err}
        flash["company"] = @company.attributes
        redirect_to "/?filter=new_company"
      end
    elsif !(generic_params[:next_id]).blank?
      redirect_to "/?id=#{generic_params[:next_id]}"
    else
      redirect_to "/?id=#{@company.id}"
    end
  end


  def generic_params(*args)
    params.permit(:all, :category, :id, :authenticity_token, :update_key, :update_value, :cmd, :filter, :next_id, :most_recent_skip_count, :autoscroll, :category_id)
  end

  def company_params
    params.permit(
      :name, :desc, :applied, :rejected, :skip, :notlaughing, :todo, :jobs, :category
    ).reject { |k,v| v.blank? }
  end

end

# bin/rails server -p $PORT -e $RAILS_ENV
