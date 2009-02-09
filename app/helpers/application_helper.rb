# = Application Helper
#
# Purpose: Create helper methods which will be available to all templates in the application.
#
module ApplicationHelper
  
  #
  # Purpose: Create a link for a menu item
  #
  # Input: A menu item (hash) - menu items are hashes of useful menu attributes. They are created in the menu_setup method in the application controller (application.rb)
  # Output: 
  # * If the iem has an action and a controller a link to those are created
  # * Otherwise, the menu item is returned as a span element with no link
  #
  def menu_link(item)
    if item[:controller] && item[:action]
      link_to item[:label], :controller => item[:controller], :action => item[:action], :params => item[:params]
    else
      "<span>#{item[:label]}</span>"
    end
  end
  
  
  #
  # Purpose: Determine if a menu has any sub-items which are considered the "current" page
  #
  # Input: 
  # * current - The current page
  # * items - An array of menu items
  #
  # Output:
  # * True, if the any of the given items, or their subitems match the current page
  # * False, otherwise
  #
  def has_active_element?(current, items)
    return false if items.blank?
    
    for item in items
      return true if active_item?(current, item)
      
      return true if has_active_element?(current, item[:submenu])
    end
    
    return false
  end
  
  
  #
  # Purpose: Determine if a particular menu_item (see application.rb) is matches the current page
  #
  # Input: 
  # * current - The current page
  # * item - The menu item to check
  # 
  # Output:
  # * True, if the values in current match the values in item
  # * False, otherwise
  #
  def active_item?(current, item)
    item_hash = {:controller => item[:controller], :action => item[:action]}.merge(item[:params] || Hash.new)
    item_params = {}
    item_hash.each{|k,v| item_params[k.to_s] = v.to_s}
    is_subset = true
    item_params.each { |k,v| is_subset = false if current[k] != v }
    return is_subset
  end
  
end
