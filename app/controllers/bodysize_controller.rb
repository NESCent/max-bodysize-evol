# 
# Graphs are created using the google charts gem (gchartrb)
#
require 'google_chart'


#
# Helper class which maintains information about fields that are used to group search results
#
require 'result_group_field'


#
# Include the bodysize graphing library
#
require 'body_size/graph'


#
# = Bodysize Controller
# Purpose: To handle all requests for things related to creating, modifying, viewing, finding, and analyzing body size records
#
class BodysizeController < ApplicationController

  

  #
  # Include libraries which allow importing records from CSV format files
  #
  require 'body_size/error'
  require 'body_size/import'
  
  
  # 
  # Purpose: The default action for bodysize is list. The index action is here for convienence. 
  # Input: None
  # Output: None
  #
  def index
    redirect_to :action => :list
  end

  # 
  # Purpose: to show the home page
  #
  def home
    prepare_for_search
    render :template =>"bodysize/home"
  end

  # 
  # Purpose: to show the home page
  #
  def about
    render :template =>"bodysize/about"
  end

  # 
  # Purpose: Compile a list of records, and graphs depending on the options the user chooses.
  # Input: None
  # Although this method does not take any arguments, the parameters that are sent greatly effect
  # the resulting behaviour. The parameters should be sent by POST and are all given in the "bodysize" namespace.
  # See "prepare_search" for details on what parameters are used.
  #
  # Output: 
  # If "list" is requested by GET, it results in a full page being rendered with the appropriate bodysize records, and graphs
  # This action is also requested by POST from ajax calls which result in a partial template being rendered instead.
  #
  # Side Effects: Search, sort, group, and graph parameters are saved in the user's session, and are sometimes used
  # in subsequent requests to reproduce the requested results.
  #
  def list
    if !params[:bodysize] && !request.post?
      session[:search] = nil
    end
    
    prepare_search(params[:bodysize])
    
    if request.post?
      ## Display search results
      if !params[:need_template]
           render :partial => 'search_results', :locals => { :user => @current_logged_in_user, 
                                                        :bodysizes => @bodysizes, 
                                                        :grouping_field => @grouping_field, 
                                                        :data_field => @data_field,
                                                        :show_export => true,
                                                        :ajax_pagination => true,
                                                       :total_records_for_graph => @total_records_for_graph}
      else
        render :template => 'bodysize/list', :locals => { :user => @current_logged_in_user, 
                                                        :bodysizes => @bodysizes, 
                                                        :grouping_field => @grouping_field, 
                                                        :data_field => @data_field,
                                                        :show_export => true,
                                                        :ajax_pagination => true,
                                                       :total_records_for_graph => @total_records_for_graph}
      end
      return
    end
  end  
  
  #
  # Purpose: Propare options for the the search form
  #
  def prepare_for_search()
    @period_options = Period.options_by_midpoint
    @start_period_options = [["Start Period",""]]
    @start_period_options.concat @period_options
    @end_period_options = [["End Period",""]]
    @end_period_options.concat @period_options

    @kingdom_options = Kingdom.options
    @phylum_options = Phylum.options
    @environment_options = Environment.options
    @motility_options = Motility.options


    ## Create a list of things that can be used to group bodysize search results
    @groups = Hash.new
    @groups["kingdom_id"] = ResultGroupField.new("kingdom_id", :display_name => "Kingdom")
    @groups["phylum_id"] = ResultGroupField.new("phylum_id", :display_name => "Phylum")
    @groups["class_classification"] = ResultGroupField.new("class_classification", :display_name => "Class", :attribute_name => "class_classification")
    @groups["environment_id"] = ResultGroupField.new("environment_id", :display_name => "Environment")
    @groups["motility_id"] = ResultGroupField.new("motility_id", :display_name => "Motility")

    @graph_group_options = @groups.map { |key, group| [group.display_name, group.field_name] }

    @groups["period_id"] = ResultGroupField.new("period_id", :display_name => "Period")
    @group_options = @groups.map { |key, group| [group.display_name, group.field_name] }
  end
  #
  # Purpose: Complete the necessary preparations to give the user the choices needed to search bodysize records. 
  # This method also begins the search process when requested.
  #
  # Input:
  # * options - Options given are merged with default options, and options from saved from previous searches in the user's
  # session, all of which are then passed on to the search method to initiate a bodysize search.
  # In addition to those options detailed for the search method, options include:
  # * * use_log10_biovolume: when set to "1", log10 biovolume will be displayed instead of biovolume.
  # * * page: The page number to display when there are enough results to necessitate pagination.
  #
  # Note that all options are stored in the user's session. These options will be used in subsequent requests unless
  # new options are provided which override the previous values.
  def prepare_search(options = {})
    logger.debug("List, Search, or Group records")
    
    @period_options = Period.options_by_midpoint
    @start_period_options = [["Start Period",""]]
    @start_period_options.concat @period_options
    @end_period_options = [["End Period",""]]
    @end_period_options.concat @period_options

    @kingdom_options = Kingdom.options
    @phylum_options = Phylum.options
    @environment_options = Environment.options
    @motility_options = Motility.options


    ## Create a list of things that can be used to group bodysize search results
    @groups = Hash.new
    @groups["kingdom_id"] = ResultGroupField.new("kingdom_id", :display_name => "Kingdom")
    @groups["phylum_id"] = ResultGroupField.new("phylum_id", :display_name => "Phylum")
    @groups["class_classification"] = ResultGroupField.new("class_classification", :display_name => "Class", :attribute_name => "class_classification")
    @groups["environment_id"] = ResultGroupField.new("environment_id", :display_name => "Environment")
    @groups["motility_id"] = ResultGroupField.new("motility_id", :display_name => "Motility")

    @graph_group_options = @groups.map { |key, group| [group.display_name, group.field_name] }

    @groups["period_id"] = ResultGroupField.new("period_id", :display_name => "Period")
    @group_options = @groups.map { |key, group| [group.display_name, group.field_name] }
    

    # Override default search values with anything in the session
    search_values = Hash.new
    if session[:search]
      session[:search].each { |key, value| search_values[key.to_sym] = session[:search][key] }
    end
      
    # Override default and session values with anything in params
    if options
      options.each { |key, value| search_values[key.to_sym] = options[key]  }
    end
    
    if params[:page]
      search_values[:page] = params[:page]
    end

    # Save the search criteria 
    session[:search] = search_values.dup
    session[:search][:show_all] = false


    if search_values && search_values[:use_log10_biovolume] && search_values[:use_log10_biovolume] == "1"
      @data_field = "log10_biovolume"
    else
      @data_field = "biovolume"
    end

    # Default records
   
    
    @bodysizes = current_user.accessible_bodysize_records({ :page => params[:page] || 1, :per_page => 20 })
    
  
    search(search_values)
  end
  
  def get_data(bodysizes, grouping_field)
      results = Hash.new
      bodysizes.each do |specimen|
        field_value = specimen.send(grouping_field.attribute_name)
        results[field_value] ||= Array.new
        results[field_value] << specimen
      end
      
      return results
  end
  
  #
  # Purpose: To find bodysize records based on the given options. If the correct options are given, graphs of the resulting
  # data will also be produced.
  #
  # Input: options - a hash of options which are used as follows:
  # * kingdom_id: If given, only records with the given kingdom will be included
  # * phylum_id: If given, only records with the given phylum will be included
  # * environment_id: If given, only records with the given environment will be included
  # * motility_id: If given, only records with the given motility will be included
  # * class_classification:  If given, only records which _contain_ the given classification will be included (case-insensitive)
  # * start_period_midpoint: If given, only records which have a period midpoint that is at, or after the given midpoint will be included
  # * end_period_midpoint: If given, only records which have a period midpoint that is at, or before the given midpoint will be included
  #
  # * group_by: If the name of a bodysize field is given, the results will be grouped by the given field.
  # * show_all: If set to true, all records that meet the criteria will be returned at one time. Otherwise, the results will be paginated.
  # * page: If show_all is not true, then the value given in page is used to choose which of the paginated result sets should be returned.
  # * graph: If a group by field is given, and graph is set to "1", then the search will also be grouped by time period, and the resulting data will be displayed by graph.
  #
  # Output: None
  # While the method does not return any specific data, a number of instance variables are set which may be used 
  # by the object in other places:
  # * @bodysizes - An array of Bodysize records that matched the search criteria.
  # * @grouping_field - The ResultGroupField object used to group the search results
  # * @periods - The Periods included in the search results
  # * @charts - An array of Bodysize::Graphs produced from the search results
  #
  def search(options = {})
    
      # Options must be given in order for any records to be found
      return if options == nil

      conditions = []

      # Limit the resulting records to records that the current user is allowed to access
      if @current_logged_in_user
        unless @current_logged_in_user.is_a?(Approver)
          conditions << ["(complete_bodysizes.approved=? OR complete_bodysizes.creator_id=?)", true, @current_logged_in_user.id]
        end 
      else
       conditions << ["(complete_bodysizes.approved=?)", true]
      end
      
      
      # Save search criteria in the list of conditions
      for field in [:kingdom_id, :phylum_id, :environment_id, :motility_id] do
        conditions << ["complete_bodysizes.#{field}=?", options[field]] unless options[field].blank?
      end

      conditions << ["lower(complete_bodysizes.class_classification) LIKE ?", "%#{options[:class_classification].downcase}%"] unless options[:class_classification].blank?
      
      start_period = options[:start_period_midpoint]
      end_period = options[:end_period_midpoint]
      periods = Period.find(:all, :order => "midpoint DESC")
      
      # Cannot do any searching when there are no periods!
      if !periods || periods.size == 0
        return
      end
      
      
      # If no start period is given, then set the start period to the midpoint of the first period
      if start_period.blank?
        start_period = periods.first.midpoint
      end
      
      # If no end period is given, then set the end period to the midpoint of the last period
      if end_period.blank?
        end_period = periods.last.midpoint
      end
      
      conditions << ["(complete_bodysizes.midpoint <= ? AND complete_bodysizes.midpoint >= ?)", start_period, end_period]
      
      ## Combine all given search criteria
      combined_conditions = Array.new
      combined_conditions << conditions.map { |condition| condition[0] }.join(" AND ")
      conditions.each do |condition|
        combined_conditions << condition[1]
        combined_conditions << condition[2] if condition[2]
      end

      
      if options[:group_by].blank?
        ## The user is searching, but has not requested any grouping of results
        if options[:show_all]
          @bodysizes =current_user.accessible_bodysize_records({ :conditions => combined_conditions })
        else
          @bodysizes = current_user.accessible_bodysize_records({ :conditions => combined_conditions, :page => options[:page] || 1, :per_page => 20 })
        end
      else  
        ## The user is requesting grouped search results
        @grouping_field = @groups[options[:group_by]]
          
        logger.debug("Results are being grouped by #{@grouping_field}")
        
        #graph_criteria = (options[:graph] == "1" && @grouping_field.field_name != "period_id") ? ", complete_bodysizes.period_id" : ""
        graph_criteria = (options[:graph] == "1" && @grouping_field.field_name != "period_id") ? ", complete_bodysizes.midpoint" : ""
        
        ## Create a query that takes into account search criteria, grouping options, and graph options
        group_maxes_sql = "(SELECT MAX(complete_bodysizes.#{@data_field}) AS max_biovolume, complete_bodysizes.#{@grouping_field.field_name} #{graph_criteria} FROM complete_bodysizes"
        group_maxes_sql += " WHERE (#{combined_conditions[0]})" if !combined_conditions[0].blank?
        group_maxes_sql += " GROUP BY complete_bodysizes.#{@grouping_field.field_name} #{graph_criteria}) AS maxes"
        full_records_grouped_by_max_sql = "complete_bodysizes INNER JOIN #{group_maxes_sql} ON maxes.max_biovolume=complete_bodysizes.#{@data_field} AND maxes.#{@grouping_field.field_name}=complete_bodysizes.#{@grouping_field.field_name}"

        sql = "SELECT DISTINCT complete_bodysizes.* FROM #{full_records_grouped_by_max_sql}"

        # Also add the original search criteria so that we don't get any extra records!
        sql += " WHERE " + Bodysize.send(:sanitize_sql, combined_conditions) if combined_conditions

        sql += " ORDER BY complete_bodysizes.#{@grouping_field.field_name} #{graph_criteria}"

        combined_conditions[0] = sql
        
        ## Run this query along with any additional criteria that may limit records the user can view
        if options[:show_all]
          @bodysizes = current_user.get_complete_records({ :conditions => combined_conditions })
        else
          @bodysizes = current_user.get_complete_records({ :conditions => combined_conditions }, { :page => params["page"] || 1, :per_page => 20 })
        end

      if options[:graph] == "1" && start_period != end_period
        logger.debug("Graph - Yes")
        ## Prepare a graph of the results
        bodysizes_for_graph = current_user.get_complete_records({ :conditions => combined_conditions })
        @total_records_for_graph=bodysizes_for_graph.size
        @periods = Period.find(:all, :conditions => ["midpoint <=? AND midpoint >=?", start_period, end_period], :order => "midpoint DESC")
        @charts = []
        
        min_period = @periods.map { |period| period.midpoint }.min
        max_period = @periods.map { |period| period.midpoint }.max
        linear_periods = (0..10).map { |x| Period.new(:midpoint => (x * (max_period-min_period) / 10) + min_period) }
        
        #step=(max_period-min_period) / 10
        #mid=min_period
        #linear_periods=[]
        #while mid<max_period do
        #  linear_periods<< Period.new(:midpoint => mid)
        #  mid+=step.to_i
        #end
        #linear_periods<< Period.new(:midpoint => mid)
        
        if bodysizes_for_graph.size>0        
          chart1 = BodySize::Graph.new(bodysizes_for_graph, linear_periods, {:grouping_field => @grouping_field, :data_field => @data_field, :period_spacing => "midpoint", :x_axis_label_row_count => 1, :title => "Maximum Body Size by #{@grouping_field} over linear time (millions of years ago)" } )
          chart2 = BodySize::Graph.new(bodysizes_for_graph, @periods, {:grouping_field => @grouping_field, :data_field => @data_field, :title => "Maximum Body Size by #{@grouping_field} over evenly spaced periods"} )
          @charts<<chart1
          @charts<<chart2
        end 
        
        #@charts << BodySize::Graph.new(bodysizes_for_graph, linear_periods, { :grouping_field => @grouping_field, :data_field => @data_field, :period_spacing => "midpoint", :x_axis_label_row_count => 1, :title => "Maximum Body Size by #{@grouping_field} over linear time (millions of years ago)" } )
        #@charts << BodySize::Graph.new(bodysizes_for_graph, @periods, { :grouping_field => @grouping_field, :data_field => @data_field, :title => "Maximum Body Size by #{@grouping_field} over evenly spaced periods"} )
      end
    end
  end

  
  
  
  #
  # Purpose: Allow administrators to view an audit trail for a particular record.
  # Input: None
  # While the method does not use any arguments, the 'id' parameter is used to identify the 
  # record for which the audit trail should be displayed.
  # Output: Results in the rendering of a partial template with the audit trail details.
  #
  def show_audit_log
    return unless authorize_admin
    
    @bodysize = Bodysize.find_by_id(params[:id])
    render :partial => 'show_audit_log'
    return
  end
  
  
  
  #
  # Purpose: Allow users to view a bodysize record
  # Input: None
  # While the method does not use any arguments, the 'id' parameter is used to identify the 
  # record which should be displayed
  # Output: The method renders the bodysize/detail template. The instance variable @editing is used by the template to determine
  # whether to display the record in view or edit mode.
  #
  # Side Effects: The event is recorded in the audit log.
  #
  def view
    @editing = false
    @bodysize = Bodysize.find_by_id(params[:id])
    
    unless @bodysize && (@bodysize.approved || @bodysize.creator == current_user || current_user.is_a?(Approver))
      flash[:warning] = "The requested record could not be found"
      redirect_to :action => :list
      return
    end
    
    if @current_logged_in_user
      AuditLog.log("Viewed a bodysize record", @current_logged_in_user.id, @bodysize.id)
    else
      AuditLog.log("Viewed a bodysize record", '-1000', @bodysize.id)
      
    end
    render :template => "bodysize/detail"
  end



  # 
  # Purpose: Allow users to create a new record
  # Input: None
  # Output: A blank bodysize record template.
  #
  def new
    unless is_authorized
      flash[:notice] = 'Please log in'
      redirect_to(:controller => 'login', :action => 'login')
    end
    prepare_bodysize_for_modification
    render :template => "bodysize/detail"
  end
  
  


  #
  # Purpose: Allow users to modify an existing bodysize record
  # Input: None
  # While no arguments are used, the 'id' parameter is used to find the record that is being modified, if it exists.
  # Otherwise, a new record is created.
  # Users can only modify an existing record if they are the record's creator, or if they are an Approver or Admin user.
  #
  def edit
    @bodysize = Bodysize.find_by_id(params[:id]) || Bodysize.new(:creator => @current_logged_in_user)
    
    unless @bodysize && (@bodysize.creator == @current_logged_in_user || @current_logged_in_user.is_a?(Approver))
      flash[:warning] = "The requested record could not be found"
      redirect_to :action => :list
      return
    end
    
    
    if request.post?
      bodysize_before_update = @bodysize
      @bodysize.approved = true if params[:commit] && params[:commit] == "Approve"
      
      if @current_logged_in_user.is_a?(Approver)
        if @bodysize.creator == @current_logged_in_user
          @bodysize.approved = true
        end
      else
        @bodysize.approved = false
      end
            
      begin
        Bodysize.transaction do
          @bodysize.update_attributes!(params[:bodysize])
        end
      rescue RuntimeError, ActiveRecord::RecordInvalid => e
        @bodysize.errors.add(:formula, e.message)
      rescue Exception => e
        flash.now[:warning] = "Errors occured while updating this record!"
        # raise e # Uncomment this for testing to see errors as they occur
      else # Saved successfully
        if @bodysize.errors.size == 0
          flash[:success] = "Your changes have been saved!"
          redirect_to :action => :edit, :id => @bodysize.id
          return
        end
        @bodysize.log_change(@current_logged_in_user, bodysize_before_update)
      end  
    end
    
    @editing = true
    @period_options = Period.options
    set_formula_options
    render :template => "bodysize/detail"
  end

  
  #
  # Purpose: Allow approvers to view unapproved bodysize records
  # Input: None
  # While the method does not use arguments, a 'page' parameter can be given to change the page displayed through pagination.
  # Output: The @bodysize instance variable contains the requested records
  #
  def unapproved
    return unless authorize_approver
    @bodysizes = Bodysize.unapproved_bodysize_records(params[:page] || 1)
  end
  
  
  
  #
  # Purpose: All administrators to import records by uploading a CSV file.
  # Input: The 'csv[datafile]' parameter should contain the csv file's data.
  # Output: Upon successful upload, the user is sent to the bodysize record list. If the upload fails, the user remains on the bodysize modification page.
  #
  # Side Effects: If successful, the event is noted in the audit log.
  #
  def import
    return unless authorize_admin

    if params[:csv]
      import = BodySize::Import::CSV.new(params[:csv][:datafile].read, 
        { :user => @current_logged_in_user }
      )

      begin
        import.execute()
      rescue BodySize::ImportError => error
        prepare_bodysize_for_modification()
        
        error.errors.each do |single_error|
          @bodysize.errors.add_to_base(single_error)
        end
        
        render :template => "bodysize/detail"
        return
        
      rescue RuntimeError => error
        flash[:warning] = "An error occured while importing records: #{error.message}"
        prepare_bodysize_for_modification
        render :template => "bodysize/detail"
        return
      else
        AuditLog.log("Imported bodysize records", @current_logged_in_user.id)
        flash[:success] = "Your records have been saved!"
        redirect_to :action => :list
        return
      end

    end
    
  end
  
  
  
  #
  # Purpose: Allow users to export bodysize records to CSV format
  # Input: None
  # Export uses the same search preparation as normal searching. See prepare_search for details.
  # If no parameters are given, prepare_search will instead use the search criteria which is stored
  # in the user's session, which is the search criteria that the user last used. 
  # Output: The resulting records are not paginated and are not displayed to screen. Instead a CSV file
  # is created and returned to the user.
  #
  def export
    prepare_search({:show_all => true})

    # BodySize::Export::CSV.new(data)
    # where data represents a collection of Active Record Bodysize objects to export
    export = BodySize::Export::CSV.new(@bodysizes, :fields_to_include => [
          "kingdom", "phylum", "class_classification", "order_classification",
           "family", "genus", "species", "environment",  "motility",
           "feeding", "period", "epoch","expert_contacted",
            "literature_citation", "other_data_source", "confidence_comment",
            "compiler", "first_description_literature_source", "length",
            "width", "height", "how_estimation_was_achieved", "mass",
            "biovolume", "log10_biovolume", "formula", "notes",
            "stage", "confidence_score", "lithology","preservation_mode",
            "location", "formation_location", "member", "bed",
            "local_environment", "regional_environment",
            "created_at","creator"])
          
    begin
        export.execute()
    rescue BodySize::ExportError
        # the export failed
        flash[:warning] = "An error occured during the export process."
        redirect_to :action => :list
        return
    else
        send_data(export.csv_string, options = { :filename => "Bodysize Records.csv" }) 
    end
  end

  
  
  #
  # Purpose: Allow approvers to approve bodysize records.
  # Input: The 'id' parameter is used to identify the bodysize record which is being approved.
  # Output: None
  #
  # Side Effects: The event is recorded in the audit log
  #
  def approve
    @bodysize = Bodysize.find_by_id(params[:id])
    
    if @current_logged_in_user.is_a?(Approver)
      @bodysize.approved = true
      @bodysize.save
      AuditLog.log("Approved a bodysize record", @current_logged_in_user.id, @bodysize.id)
    end
  end
  
  
  #
  # Purpose: Allow approvers to unapprove bodysize records.
  # Input: The 'id' (int) parameter is used to identify the bodysize record which is being unapproved.
  # Output: None
  #
  # Side Effects: The event is recorded in the audit log
  #
  def unapprove
    @bodysize = Bodysize.find_by_id(params[:id])
    if @bodysize && @current_logged_in_user.is_a?(Approver)
      logger.debug("Attempt to unapprove. User is approver")
      @bodysize.approved = false
      if @bodysize.save
        AuditLog.log("Unapproved a bodysize record", @current_logged_in_user.id, @bodysize.id)
      else
        logger.warn("Attempt to unapprove bodysize failed on save")
      end
    end
  end
  
  
  #
  # Purpose: Allow approvers to delete unapproved bodysize records.
  # Input: The 'id' (int) parameter is used to identify the bodysize record which is being removed.
  # Output: None
  #
  # Side Effects: The event is recorded in the audit log
  #
  def delete
    return unless authorize_approver
    
    @bodysize = Bodysize.find_by_id(params[:id])
    name = @bodysize.to_s
    
    if request.post? && !@bodysize.approved
      @bodysize.destroy
      flash[:success] = "#{name} has been deleted"
      AuditLog.log("Deleted the bodysize record called #{name}", @current_logged_in_user.id)
    else
      flash[:warning] = "#{name} can not be deleted"
    end
    
    redirect_to :action => :unapproved
  end
    
 
 
 #
 # Purpose: Allow users to comment on records
 # Input: 
 # * The 'id' (int) parameter is used to identify the bodysize record which is being commented on.
 # * The 'comment' (string) parameter is used as the body of the new comment
 # Output: A partial template is rendered with all comments for the record
 #
 def add_comment
   @bodysize = Bodysize.find_by_id(params[:id])
   
   if @bodysize && params[:comment]
     @bodysize.public_comments << PublicComment.create( :comment => params[:comment],
                                                 :owner => @current_logged_in_user)
   end
   
   render :partial => "comments", :locals => { :bodysize => @bodysize }
 end
 
 
 #
 # Purpose: Allow record owners, approvers, and admins to create private notes for a record
 # Input:
 # * The 'id' (int) parameter is used to identify the bodysize record.
 # * The 'note' (string) parameter is used as the body of the note 
 # Output: A partial template is rendered with all notes for the record
 #
 def add_private_note
   @bodysize = Bodysize.find_by_id(params[:id])
   return unless @current_logged_in_user.can_edit?(@bodysize)
   
   if @bodysize && params[:note]
     @bodysize.private_notes << PrivateNote.create( :comment => params[:note],
                                                 :owner => @current_logged_in_user)
   end
   
   render :partial => "private_notes", :locals => { :bodysize => @bodysize }
 end
  
  
  #
  # Purpose: Allow administrators to remove comments, and notes
  # Input:
  # * The 'id' (int) parameter is used to identify the comment which is being removed.
  # Output: A partial template is rendered with all comments for the record upon success
  # If the comment id is invalid, an error message is displayed.
  #
  def remove_comment
    return unless authorize_admin
    
    comment = Comment.find_by_id(params[:id])
    
    if comment
      bodysize = comment.bodysize
      comment.destroy
      
      if comment.is_a?(PublicComment)
        render :partial => "comments", :locals => { :bodysize => bodysize }  
        return
      elsif comment.is_a?(PrivateNote)
        render :partial => "private_notes", :locals => { :bodysize => bodysize }  
        return
      end
    end
    
    render :text => "The selected comment could not be found"
  end
  
  
  private
  
  
  #
  # Purpose: Prepare a bodysize record for modification
  # Input: 
  # * The 'id' (int) parameter is used to identify record which is to be modified
  #
  # Output:
  # * The @editing instance variable is set to true
  # * The @bodysize instance variable contains the bodysize record what will be modified
  # * The @period_options instance varaible contains the list of all Periods to be displayed in the Period drop down list.
  #
  def prepare_bodysize_for_modification # :doc:
    @editing = true
    @bodysize = Bodysize.find_by_id(params[:id]) || Bodysize.new(:creator => @current_logged_in_user)
    @period_options = Period.options
    set_formula_options
  end
  
  
  #
  # Purpose: Prepare the drop-down options for the current user in the Formula drop-down field
  # Input: None
  # Output: An array of drop-down options
  #
  def set_formula_options # :doc:
    @formula_options = [["New Formula...","new_formula"]]
    # This may cause issues when the user has no accessible formulae
    @formula_options.concat current_user.accessible_formulas.map { |formula| formula.to_option }
  end
  
end
