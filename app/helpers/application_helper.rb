module ApplicationHelper
  def get_page_name_and_companies_query(session)
    if session["only_todos"]
      ["showing todos", Company.todo]
    elsif session["most_recent_skips"]
      ["showing skipped", Company.skipped]
    elsif session["no_filter"]
      ["showing all", Company.all]
    elsif session["starred"]
      ["showing starred", Company.unscoped.where(starred: true)]
    else
      ["showing blanks", Company.blank]
    end
  end
  def get_next_and_previous(company, query)
    previous_company = query.where("id < ?", @company&.id).last ||\
                  query.order(id: :desc).first ||\
                  @company.get_previous ||\
                  @company.get_next ||\
                  @company
    next_company = query.where("id > ?", @company&.id).first ||\
                   query.first ||\
                   @company.get_next ||\
                   @company.get_previous ||\
                   @company
    [
      {id: previous_company.id, name: previous_company.name},
      {id: next_company.id, name: next_company.name}
    ]
  end


end
