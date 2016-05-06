class PagesController < ApplicationController
  def root
    if params[:autoscroll] == "on"
      session["autoscroll"] = true
    elsif params[:autoscroll] == "off"
      session["autoscroll"] = false
    end
    filter = params[:filter]
    if filter && filter.eql?("only_todos")
      session["only_todos"] = true
      session["most_recent_skips"] = false
    elsif filter && filter.eql?("not_only_todos")
      session["only_todos"] = false
      session["most_recent_skips"] = false
    elsif filter && filter.eql?("most_recent_skips")
      session["most_recent_skips"] = true
      @most_recent_skip_count = params[:most_recent_skip_count] || session["most_recent_skip_count"] || 5
      session["most_recent_skip_count"] = @most_recent_skip_count
      session["only_todos"] = false
    end
    @most_recent_skip_count = session["most_recent_skip_count"] || 5
    @percentage_completed = "#{((Company.nonblank.count.to_f / Company.count.to_f) * 100.to_f).round(2)}%"
    @todos_count = Company.todo.count
    @application_count = Company.applied.count
    @skipped_count = Company.skipped.count
    if params[:id]
      @company = Company.find(params[:id])
    else
      if session["only_todos"]
        @company = Company.todo.limit(1).first
      elsif session["most_recent_skips"]
        @most_recent_skips = Company.skipped.last(@most_recent_skip_count)
      else
        @company = Company.blank.limit(1).first
      end
    end
  end

  def update
    @company = Company.find(params[:id])
    cmd = params[:cmd]
    case cmd
    when "quick_skip"
      @company.update(skip: "true")
    when "quick_apply"
      @company.update(applied: "true")
    when "quick_todo"
      @company.update(todo: "true")
    when "quick_rejected"
      @company.update(rejected: "true")
    when "skip_with_note"
      @company.update(skip: params[:update_value])
    when "apply_with_note"
      @company.update(applied: params[:update_value])
    when "todo_with_note"
      @company.update(todo: params[:update_value])
    when "not_laughing"
      @company.update(notlaughing: params[:update_value])
    when "undo_todo"
      @company.update(todo: nil)
    when "undo_skip"
      @company.update(skip: nil)
    end
    if params[:next_id]
      redirect_to "/?id=#{params[:next_id]}"
    else
      redirect_to "/?id=#{@company.id}"
    end
  end


  def params(*args)
    super(*args).permit(:all, :category, :id, :authenticity_token, :update_key, :update_value, :cmd, :filter, :next_id, :most_recent_skip_count, :autoscroll)
  end

end
