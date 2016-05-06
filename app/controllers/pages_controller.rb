class PagesController < ApplicationController
  def root
    if generic_params[:autoscroll] == "on"
      session["autoscroll"] = true
    elsif generic_params[:autoscroll] == "off"
      session["autoscroll"] = false
    end
    filter = generic_params[:filter]
    if filter && filter.eql?("only_todos")
      session["only_todos"] = true
      session["most_recent_skips"] = false
      session["no_filter"] = false
    elsif filter && filter.eql?("no_filter")
      session["only_todos"] = false
      session["most_recent_skips"] = false
      session["no_filter"] = true
    elsif filter && filter.eql?("not_only_todos")
      session["only_todos"] = false
      session["most_recent_skips"] = false
      session["no_filter"] = false
    elsif filter && filter.eql?("most_recent_skips")
      session["only_todos"] = false
      session["most_recent_skips"] = true
      session["no_filter"] = false
      @most_recent_skip_count = generic_params[:most_recent_skip_count] || session["most_recent_skip_count"] || 5
      session["most_recent_skip_count"] = @most_recent_skip_count
    end
    @most_recent_skip_count = session["most_recent_skip_count"] || 5
    @percentage_completed = "#{((Company.nonblank.count.to_f / Company.count.to_f) * 100.to_f).round(2)}%"
    @todos_count = Company.todo.count
    @application_count = Company.applied.count
    @skipped_count = Company.skipped.count
    if generic_params[:filter] && generic_params[:filter].eql?("new_company")
      @company = Company.new
    elsif generic_params[:id]
      @company = Company.find(generic_params[:id])
    else
      if session["no_filter"]
        @company = Company.first
      elsif session["only_todos"]
        @company = Company.todo.limit(1).first
      elsif session["most_recent_skips"]
        @most_recent_skips = Company.skipped.last(@most_recent_skip_count)
      else
        @company = Company.blank.limit(1).first
      end
    end
  end

  def category_toggler
    @categories = Category.all.order(id: :desc)
    if generic_params[:cmd] && generic_params[:cmd].eql?("toggle")
      @category = Category.find_by(id: generic_params[:category_id])
      @category.update(hidden: !@category.hidden)
      redirect_to "/category_toggler"
    else
      render "category_toggler"
    end
  end

  def update
    @company = Company.find_by(id: generic_params[:id])
    cmd = generic_params[:cmd]
    case cmd
    when "add_company"
      add_company = true
      @company = Company.create(company_params)
    when "set_category"
      @company.update(category: generic_params[:update_value])
    when "quick_skip"
      @company.update(skip: "true")
    when "quick_apply"
      @company.update(applied: "true")
    when "quick_todo"
      @company.update(todo: "true")
    when "quick_rejected"
      @company.update(rejected: "true")
    when "skip_with_note"
      @company.update(skip: generic_params[:update_value])
    when "apply_with_note"
      @company.update(applied: generic_params[:update_value])
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
    end
    if add_company
      redirect_to "/?id=#{@company.id}"
    elsif generic_params[:next_id]
      redirect_to "/?id=#{generic_params[:next_id]}"
    else
      redirect_to "/?id=#{@company.id}"
    end
  end


  def generic_params(*args)
    params.permit(:all, :category, :id, :authenticity_token, :update_key, :update_value, :cmd, :filter, :next_id, :most_recent_skip_count, :autoscroll, :category_id)
  end

  def company_params
    params.permit(:name, :desc, :applied, :rejected, :skip, :notlaughing, :todo, :jobs, :category)
  end

end
