module ApplicationHelper

  # Returns the full app title on a per-page basis, or a default if
  # no page title is specified.
  def full_title(page_title)
    title = 'Ruby on Rails Tutorial App'
    unless page_title.empty?
      title << ' | ' << page_title
    end
    return title
  end

end
