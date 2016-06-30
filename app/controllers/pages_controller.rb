class PagesController < ApplicationController

  def get_remoteok_listings
    Category.find_or_create_by(name: "remoteok")
    JSON.parse(`curl https://remoteok.io/index.json`).each do |listing|
      company = Company.new(
        name: listing["company"],
        desc: "#{listing['position']} - #{listing["tags"].join(",")} - #{listing["description"]}",
        category: "remoteok"
      )
      if params[:query]
        company.save if company.desc.include?(params[:query])
      else
        company.save
      end
    end
    redirect_to :back
  end
  def get_indeed_listings
    Category.find_or_create_by(name: "indeed")
    0.upto(7).to_a.each do |i| # get 7 pages
      job_query = { start: (25 * i), limit: 25 }
      !params[:search_term].blank? && (job_query[:search_term] = params[:search_term])
      FindJobListings::Indeed_API.new.jobs(job_query).each do |company|
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
    job_query = { start: (0), limit: 50 }
    !params[:search_term].blank? && (job_query[:search_term] = params[:search_term])
    FindJobListings::StackOverflow_API.new.jobs(job_query)&.each do |company|
      company = Company.create(
        name: company[:title].split("at ")[-1].split(" (")[0],
        desc: company[:description] + " - " + company[:location],
        jobs: company[:link],
        category: "stackoverflow"
      )
    end
    redirect_to :back
  end

  def root
    completed_pct = ((Company.nonblank.count.to_f / Company.count.to_f) * 100.to_f).round(2)
    @percentage_completed = "#{completed_pct}%"
    @todos_count = Company.todo.count
    @application_count = Company.applied.count
    @skipped_count = Company.skipped.count
    # Some helper methods called from application_controller:
    set_autoscroll
    set_current_page
    define_current_company
#     setup_data_csv_for_graph
  end

  def category_toggler
    @categories = Category.all.order(id: :desc)
    if generic_params[:cmd] == "toggle"
      @category = Category.find_by(id: generic_params[:category_id])
      @category.update(hidden: !@category.hidden)
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
    when "quick_skip"
      @company.update(skip: "true", todo: nil)
    when "quick_apply"
      @company.update(applied: "true", todo: nil)
    when "quick_todo"
      @company.update(todo: "true")
    when "quick_rejected"
      @company.update(rejected: "true", todo: nil)
    when "skip_with_note"
      @company.update(skip: generic_params[:update_value], todo: nil)
    when "apply_with_note"
      @company.update(applied: generic_params[:update_value], todo: nil)
    when "todo_with_note"
      @company.update(todo: generic_params[:update_value])
    when "not_laughing"
      @company.update(notlaughing: generic_params[:update_value])
    when "undo_todo"
      @company.update(todo: nil)
    when "undo_skip"
      @company.update(skip: nil)
    when "star"
      @company.update(starred: true)
    when "unstar"
      @company.update(starred: false)
    when "undo_apply"
      @company.update(applied: false)
    when "add_company"
      is_add_company_request = true
      add_company # see application controller
    when "set_category"
      set_category # see application controller
    end
    is_company_persisted = @company.persisted?
    set_recently_edited_companies if is_company_persisted
    if is_add_company_request && is_company_persisted
      redirect_to "/?id=#{@company.id}"
    elsif is_add_company_request # error adding the company
        @company.errors.full_messages.each { |err| flash[:messages] << err}
        flash["company"] = @company.attributes
        redirect_to "/?filter=new_company"
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
