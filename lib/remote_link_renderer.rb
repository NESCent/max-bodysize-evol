# = AJAX Link Renderer
#
# Purpose: Allow will paginate to produce ajax links
#
class AjaxLinkRenderer < WillPaginate::LinkRenderer
  
  #
  # Purpose: prepare a link (see WillPaginate::LinkRenderer for details)
  #
  # Input: collection, options, template (see WillPaginate::LinkRenderer for details)
  # Output:
  # * The instance variable @remote is set
  #
  def prepare(collection, options, template)
    @remote = options.delete(:remote) || {}
    super
  end


protected

  #
  # Purpose: create an ajax link for pagination
  # 
  # Input: 
  # * page (integer) - The page number to which it should link
  # * text (string) - The text that should appear as the clickable area of the link
  # * attributes (hash) [optional] - Any additional attributes as defined by link_to
  #
  def page_link(page, text, attributes = {})
    @template.link_to_remote(text, {:url => url_for(page), :method => :get}.merge(@remote))
  end
  
end