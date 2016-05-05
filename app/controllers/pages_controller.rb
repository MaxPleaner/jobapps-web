class PagesController < ApplicationController
  def root
    if params[:all]
      @companies = Company.all
      category = params[:category]
      if category
        @companies = Company.where(category: category)
      end
    elsif params[:id]
      @company = Company.find(params[:id])
    else
      @company = Company.blank.limit(1).first
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
    end
    redirect_to :back
  end


  def params(*args)
    super(*args).permit(:all, :category, :id, :authenticity_token, :update_key, :update_value, :cmd)
  end

end
