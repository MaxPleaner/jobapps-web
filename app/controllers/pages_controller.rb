class PagesController < ApplicationController
  def root
    filter = params[:filter]
    if filter && filter.eql?("only_todos")
      session["only_todos"] = true
    elsif filter && filter.eql?("not_only_todos")
      session["only_todos"] = false
    end
    @percentage_completed = "#{((Company.nonblank.count.to_f / Company.count.to_f) * 100.to_f).round(2)}%"
    @todos_count = Company.todo.count
    @application_count = Company.applied.count
    @skipped_count = Company.skipped.count
    if params[:id]
      @company = Company.find(params[:id])
    else
      if session["only_todos"]
        @company = Company.todo.limit(1).first
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
    end
    if params[:next_id]
      redirect_to "/?id=#{params[:next_id]}"
    else
      redirect_to "/?id=#{@company.id}"
    end
  end


  def params(*args)
    super(*args).permit(:all, :category, :id, :authenticity_token, :update_key, :update_value, :cmd, :filter, :next_id)
  end

end
