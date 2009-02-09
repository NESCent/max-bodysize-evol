module FeedbackHelper

  def feedback_link
    app_array = request.session_options[:session_key].split('_')
    application_name = app_array[1, app_array.length-3].join('_')
    
    params_string = "application=#{application_name}"
    params_string << hash_substring(params, '&p')
    params_string << hash_substring(session.data, '&s')
    
    #return link_to('Report bug or need help ', 
    #   "http://feedback.netfriends.com:8005/feedback_submit/submit?#{params_string}", 
    #   :popup => true)
    
    return link_to('Report bug or need help ', 
       "mailto: bodysize-help@nescent.org", 
       :popup => false)
    
  end
  
  private
  
  def hash_substring(hash, prefix)
    substring = ''
    hash.each do |key, value|
      if value.is_a? Hash
        substring << hash_substring(value, "#{prefix}[#{CGI.escape(key.to_s)}]")
      else
        substring << "#{prefix}[#{CGI.escape(key.to_s)}]=#{CGI.escape(value.to_s)}"
      end
    end
    return substring
  end

end