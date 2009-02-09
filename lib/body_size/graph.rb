# = BodySize Module
#
# Purpose: Keep BodySize specifc classes in their own namespace to avoid problems.
#

module BodySize

  
  #
  # Purpose: Maintain information about a Label which will appear on a graph
  #
  class Label
    
    #
    # Purpose: Allow access to instance variables
    # * name (string) - The name of the Label (this will appear as the label on the graph)
    # * position (float) - The position of the label.
    attr_accessor :name, :position
    
    
    #
    # Purpose: Create a new Label
    #
    # Input: 
    # * name (string) - The name of the label
    # * position (float) - The position of the label
    #
    def initialize(name, position)
      @name = name
      @position = position.to_f
    end
    
    
    #
    # Purpose: Scale the label based on the dimensions of the graph
    #
    # Input: 
    # * max_x_value (float) - The maximum value that any data point takes on the graph
    # * x_range_max (float) - The maximum value displayed on the graph's scale (even if no data is at that point)
    #
    # Output: Sets @position to the position of the label after scaling
    #
    def scale_position_reverse(x_range, x_axis_range)
      #puts "Scaling #{@position} with max val #{x_range.max} and max range #{x_axis_range.max} to:"
#      @position = x_axis_range.max - (((x_axis_range.max) * (@position - x_range.min)) / (x_range.max)
      @position = x_axis_range.max - (@position - x_range.min) / ((x_range.max - x_range.min) / x_axis_range.max)
      
      # If the number is very small it will be given in scientific notation, which google charts does not understand
      if @position.abs < 0.01
        @position = 0.0
      end
      
      #puts @position
    end
    #
    # Purpose: Scale the label based on the dimensions of the graph from top to bottom or from right to left
    #
    # Input: 
    # * range (float) - The set of min and max values that any data point takes on the graph
    # * axis_range (float) - The set of min and max values displayed on the graph's scale (even if no data is at that point)
    # * reverse (boolean) - whether or not reverse the direction
    # Output: Sets @position to the position of the label after scaling
    #
    def scale_position(range,axis_range,reverse=false)
      @position = (@position - range.min) / (range.max - range.min) *(axis_range.max-axis_range.min)
      
      if reverse
         @position =axis_range.max-@position
      else
         @position =axis_range.min+@position
      end
        
      # If the number is very small it will be given in scientific notation, which google charts does not understand
      if @position.abs < 0.01
        @position = 0.0
      end
    end
  end
  
  
  #
  # Purpose: Represent a row of labels
  #
  class LabelRow
    
    
    #
    # Purpose: Allow access to instance variables
    # * labels (Array of Labels) - The labels that make up a particular row
    #
    attr_accessor :labels
    
    
    #
    # Purpose: Create a new LabelRow
    # Input: None
    # Output: None
    #
    def initialize
      @labels = []
    end
    
    
    #
    # Purpose: Add a label to the row
    #
    # Input: label (Label) - The label to add
    # Output: @labels is updated
    #
    def add_label(label)
      @labels << label
    end
    
    
    #
    # Purpose: Retrieve a label by number
    #
    # Input: number (integer) - The label to retrieve by the order in which it was added
    # Output: Label - the label requested
    #
    def get_label(number)
      return @labels[number]
    end
    
    
    #
    # Purpose: Retrieve the names of all of the labels
    #
    # Input: None (uses @labels)
    # Output: Array (of strings) - a list of all the label names
    #
    def get_names
      return @labels.map { |label| label.name }
    end
    
    
    #
    # Purpose: Retrieve the position of all labels in the row
    #
    # Input: None (uses @labels)
    # Output: Array (of floats) - a list of all the label positions
    #
    def get_positions
      return @labels.map { |label| label.position }
    end
  end
  
  
  
  #
  # == Graph
  #
  # Purpose: Create a graph of bodysize records
  #
  class Graph
    
    
    #
    # Purpose: Allow access to the graph url
    # * graph (string) - The url encoded to create a google chart
    #
    attr_accessor :graph, :title
    
    
    #
    # Purpose: Create Labels for the graph
    #
    # Input: 
    # * periods (Array of Periods) - The periods to use as the labels of the graph
    # * period_spacing (String) - The type of spacing that should be used to position the labels
    #
    # Output: Returns an Array of Labels
    #
    def create_x_labels(periods, period_spacing,minx=nil,maxx=nil)
      maxx = periods.map { |period| period.midpoint }.max unless maxx
      minx = periods.map { |period| period.midpoint }.min unless minx
      step=0
      
      if periods.size==1
        step= (maxx-minx)/2
      else
        step=(maxx-minx)/(periods.size-1)
      end
      
      
      labels = Array.new
      label_number = 0
      periods.each do |period|
        if period_spacing == "midpoint"
          label = Label.new(period.midpoint, period.midpoint)
        else
          label = Label.new(period.name, (periods.size-label_number-1)*step)
        end
        
        labels << label
        label_number += 1
      end
      
      return labels
    end
    
    def get_graceful_label_step(minv,maxv,num)
      digits=((maxv-minv)/num).to_s.split(//)
      pos1=-1
      d1=0
      pos2=-1
      d2=0
      dot_pos=-1
      neg=false
      
      0.upto(digits.size-1) do |i|
        if digits[i]=="-"
          neg=true
        elsif digits[i]=="."
          dot_pos=i
        elsif digits[i]!="0"
          if pos1 != -1
            pos1=i
            d1=digits[i]
          elsif pos2!=-1
            pos2=i
            d2=digits[i]
          end
        end
      end
      
      step=1
      if dot_pos!=-1
        if neg
          step=0
        end 
      end
      
      return step
    end
     #
    # Purpose: Create Labels for the y-axis
    #
    # Input: 
    # * value_range (Array of min and max values)
    # * label_number (integer) - The number of labels
    #
    # Output: Returns an LabelRow
    #
    def create_y_label_row(value_range, label_number)
      label_row=LabelRow.new
      
      step=((value_range[1]-value_range[0])/(label_number-1))
      (0..label_number-1).each do |index|
        label = Label.new(value_range[0]+index*step, value_range[0]+index*step)
        label_row.add_label(label)
      end
      
      return label_row
    end
    
    #
    # Purpose: Create Label Rows for the graph
    #
    # Input:
    # * labels (Array of Labels) - All of the labels needed or the graph.
    # * number (integer) - The number of rows to create
    #
    # Output: Returns an Array of LabelRows containing all of the given labels broken up into 'number' rows
    #
    def create_label_rows(labels, number)
      # Assign each label to a label row
      
      x_axis_label_rows = Array.new
      number.times do
        x_axis_label_rows << LabelRow.new
      end
      
      row_num = 0
      labels.each do |label|
        row_num %= x_axis_label_rows.size
        x_axis_label_rows[row_num].add_label(label)
        row_num += 1
      end
      
      return x_axis_label_rows
    end
    
    
    #
    # Purpose: Retreieve the pertinent data from each bodysize record
    #
    # Input: 
    # * bodysizes (Array of Bodysizes) - The bodysize records from which the data should be retrieved
    # * grouping_field (string) - The bodysize field to use as the data source
    #
    # Output: Returns a Hash where each key is the value that will be used as the data point on the graph for a particular record, and the value is the entire bodysize record.
    #
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
    # Purpose: Determine the position of a given period
    #
    # Input: 
    # * labels (Array of Labels) - The labels that will be displayed on the graph
    # * period (Period) - The period for which the position should be given
    #
    # Output: 
    # * The position of the given period, based on the position of the label which matches the period's name
    # * If the period does not match any of the given labels, 0 is returned
    #
    def find_period_position(labels, period) 
      labels.each do |label|
        if label.name == period.name
          return label.position
        end
      end
      
      return 0
    end
    
    
    #
    # Purpose: Create the curves that will be displayed as the data on the graph
    #
    # Input:
    # * data (Hash) - The graph data in a hash format. The key is the value to be graphed, and the value is the bodysize record 
    # * labels (Array of Labels) - The labels to display on the graph
    # * period_spacing (String) - The type of spacing that will be used for the period labels
    # * data_field (String) - The bodysize attribute that is being used as the data source for the graph
    #
    # Output: 
    # * An Array of GraphLines - The graph lines that will be displayed as the curves on the graph
    #
    def create_graph_lines(data, labels, period_spacing, data_field)
      graph_lines = Array.new
      data.each do |field_value, specimens|
        graph_line = GraphLine.new(field_value)
        specimens.each do |specimen|
          if period_spacing == "midpoint"
            graph_line.add_point(specimen.period.midpoint, specimen.read_attribute(data_field))
          else
            position = find_period_position(labels, specimen.period)
            graph_line.add_point(position, specimen.read_attribute(data_field))
          end
        end

        graph_lines << graph_line
      end
      
      return graph_lines
    end
    
    
    #
    # Purpose: Find the range of the data to be graphed
    #
    # Input: 
    # * graph_lines (Array of GraphLines) - The graph lines that will be displayed on the graph
    #
    # Output: 
    # * An array with two elements: the minimum value, and the maximum value of the graphs data
    #
    def find_range(graph_lines)
      specimen_size_range = nil
      
      for graph_line in graph_lines do
        if specimen_size_range.nil?
          specimen_size_range = [graph_line.min, graph_line.max]
        end

        min = graph_line.min
        max = graph_line.max

        specimen_size_range[0] = min if min < specimen_size_range[0]
        specimen_size_range[1] = max if max > specimen_size_range[1]
      end
      
      return specimen_size_range
    end
    
    
    #
    # Purpose: Create a new Graph object
    #
    # Input: 
    # * bodysizes (Array of Bodysizes) - The bodysize records to graph
    # * periods (Array of Periods) - The periods to include on the graph
    # * options (Hash) [optional] - Additional options including:
    # ** grouping_field (String) - The name of the field that was used to group the graph data
    # ** data_field (String) - The name of the Bodysize attribute to use as the data source
    # ** x_axis_label_row_count - The number of rows to use when displaying labels along the x-axis. (Default value is 2)
    # ** x_range - The values that should be used as the range along the x-axis (Default value is 0 - 1000)
    # ** period_spacing (String) - The way the Periods should be spaced on the graph. The options are:
    # *** "even" (default) - Periods will be evenly spaced across the graph
    # *** "midpoint" - Periods will be spaced according to their midpoint. This will give a more accurate representation of time
    #
    # *NOTE:* This graph currently sets a data point at 1000, 1000 to ensure that the axis ranges do not shrink or get scaled
    # smaller than 1000 when here are no values at the maximum points of the graph. 
    # If a better way becomes apparent to set the ranges on google charts, use that method and remove the point at 1000, 1000
    #
    def initialize(bodysizes, periods, options = {})
      GraphLine.reset_color # There might be a better way to do this
      
      grouping_field = options[:grouping_field]
      data_field = options[:data_field]
      back_ground=options[:back_ground] || ""
      taxa_names=options[:taxa_names]
      display_lines=options[:display_lines]
      @title = options[:title] || "" 
      period_spacing = options[:period_spacing] || "even"
      x_range = options[:x_range] || [0.0,100.0]
      y_range = options[:y_range] || [0.0,100.0]
      number_of_x_axis_label_rows = options[:x_axis_label_row_count] || 2
      number_of_periods = periods.size
      
      # Get the data
      results = get_data(bodysizes, grouping_field)
      
      # Create labels for each x axis
      labels = create_x_labels(periods, period_spacing)
      x_axis_label_rows = create_label_rows(labels, number_of_x_axis_label_rows)  
      
       
     
        
      # Create Graph Lines
      graph_lines = create_graph_lines(results, labels, period_spacing, data_field)
      
      # If any lines have only one point, duplicate the point so that a point will show up!
      for graph_line in graph_lines do
        if graph_line.size == 1
          graph_line.add_point(graph_line.get_point(0).dup)
        end
      end
      
      # Find the range across all lines
      specimen_size_range = find_range(graph_lines)      

     
      if !specimen_size_range.nil?
        #get min and max values for x
        max_x_value = periods.map { |period| period.midpoint }.max
        min_x_value = periods.map { |period| period.midpoint }.min
        
        if max_x_value==min_x_value
          max_x_value=max_x_value+max_x_value/2
          min_x_value=min_x_value-min_x_value/2
        end
        
        #get min and max values for y
        max_y_value = specimen_size_range[1]
        min_y_value = specimen_size_range[0]
        if max_y_value==min_y_value
          max_y_value=max_y_value+max_y_value/2
          min_y_value=min_y_value-min_y_value/2
        end   
        
        # Create an XY Line Chart
        chart = GoogleChart::LineChart.new('750x400', @title, true)
        chart.data_encoding = :simple
        chart.show_legend = true
        
        chart.max_value([min_x_value,max_y_value])
        chart.min_value([max_x_value,min_y_value])
        
        # Add the data points
        count = 0
        for graph_line in graph_lines do
          chart.data(graph_line.label, graph_line.data, graph_line.color)
          chart.shape_marker :circle, :color => graph_line.color, :data_set_index => count, :data_point_index => -1, :pixel_size => 5
          count += 1
        end
        
        
        #add sub charts
        subcharts=process_subcharts(results)
        
        subcharts.each do |subchart|
          chart.add_sub_chart(subchart)
        end
        
        #set background
        
        if back_ground=="transparent"
          chart.fill(:background, :solid, {:color =>"65432100"})  
        else
          chart.fill(:background, :gradient, {:angle => 90, :color => [['76A4FB',0],['ffffff',1]]})
        end
        
        
       
        # Scale the period label positions to the 100 - 0 scale.
        x_axis_label_rows.each do |label_row|
         label_row.labels.each do |label|
           label.scale_position([min_x_value, max_x_value], x_range,true)
         end
        end
      
        # Add each label row
        x_label_count=0
        x_axis_label_rows.each do |label_row|
          x_label_count+=label_row.get_names.size
          chart.axis :x, :labels => label_row.get_names, :range => x_range, :positions => label_row.get_positions
        end
        
        # Add the y axis labels
        y_label_row=create_y_label_row([min_y_value,max_y_value],11)
        y_label_row.labels.each do |label|
            label.scale_position([min_y_value,max_y_value], y_range)
        end
        
        #chart.axis :y, :range => [specimen_size_range[0], specimen_size_range[1]]
        chart.axis :y, :labels => y_label_row.get_names, :range => y_range, :positions => y_label_row.get_positions
        
        # Add the grid
        chart.grid :x_step => (100.0 / (x_label_count-1)),:y_step => (10), :length_segment => 1, :length_blank => 1


        
        # Save the graph for later!
        @graph = chart
      end
    end
    
    #
    # Purpose: divide lines into sub groups
    #
    # Input: 
    # * results (hash of Bodysizes) - The bodysize records to graph
    # Output: Set - set of subgroups
    #
    def process_subcharts(results)
      sub_charts=[]
      record_per_graph=20
      t=0
      subtotal=0
      bodysizes_temp=[];
      
      results.each do |field_value, specimens|
         subtotal+=specimens.size
         if subtotal>record_per_graph
             sub_charts << Array.new(bodysizes_temp)
             subtotal=specimens.size
             bodysizes_temp.clear
             bodysizes_temp<<field_value
         else
             bodysizes_temp<<field_value
         end
      end
          
      if subtotal>0
          sub_charts << Array.new(bodysizes_temp)
      end
      
      return sub_charts
    end
  end
  

  
  # == GraphLine
  #
  # Purpose: Create graph lines which can be easily sent to gchartrb to create lines on the graph
  #
  class GraphLine
    
    #
    # Purpose: Allow access to the instance variables
    # * data - The data that make up this line
    # * label (String) - The label to be displayed for this line
    # * color (String) - The hexidecimal representation of the color to be used for this line
    #
    attr_accessor :data, :label, :color
    
    
    #
    # Purpose: Define the possible colors of lines on the graph
    #
    @@colors = ["000033", "FF0033", "00FFCC", "FFFFCC", "A3A300", "0033FF", "FFCC00",
                "007070", "AD0000", "FF6699", "66FF7F", "330099", "669900", "99001A",
                "3D00F5", "8AB800", "6633FF", "33FF66", "FF6633", "6314FF", "998000"]
    
    #
    # Purpose: maintain a position in the color array, so that each subsequent line is a different color
    #
    @@next_color = 0
    
    
    def self.reset_color
      @@next_color = 0
    end
    
    
    #
    # Purpose: return the number of data points in the line
    # Input: None
    # Output: Integer - The number of data points in the line
    #
    def size
      return @data.size
    end
    
    
    #
    # Purpose: Create a new GraphLine object
    #
    # Input: label (String) [optional] - The name that should be used as the label for the line
    # Output: A new GraphLine object
    #
    def initialize(label = "")
      @label = label
      @data = []
      set_color
    end
    
    
    #
    # Purpose: Set the color of the graph line
    # Input: None (Uses @@nextcolor, and @@colors)
    # Output: None (Sets the color in @color)
    #
    def set_color
      @@next_color %= @@colors.size
      @color = @@colors[@@next_color]
      @@next_color += 1
    end
    
    
    #
    # Purpose: Add a point to the graph line
    # Input: 
    # * x (float) - The x value for the new point to add, OR an Array containing both the x and y value
    # * y (float) [optional] - The y value for the new point to add. When using the array notation, this parameter is not used
    #
    # Will accept add_point(x, y) for example: add_point(3, 5) 
    # or a point as an array
    # add_point([x, y]) for example: add_point([3, 5]) 
    #
    # Output: None (Adds the new point to @data)
    #
     def add_point(x, y = nil)
      if x.is_a?(Array)
        points = x
        x = points[0]
        y = points[1]
      end
      
      # Limit each data point to 2 decimal places
      x = sprintf("%.2f", x.to_f).to_f
      y = sprintf("%.2f", y.to_f).to_f
    
      @data << [x, y]
    end
    
    
    #
    # Purpose: Retrieve a particular point from the line
    #
    # Input: number (integer) - the index of the point to retrieve
    # Output: Array - An Array of size 2 where the first value is the value, and the second is the y value: [x, y]
    #
    def get_point(number)
      return @data[number]
    end
        
    
    #
    # Purpose: Find the minimum value of all the points in the line
    #
    # Input: None (Uses @data)
    # Output: Float - The minimum value of all the ponts in the line
    #
    def min
      data.map { |point| point.last }.min
    end
    
    
    #
    # Purpose: Find the maximum value of all the points in the line
    #
    # Input: None (Uses @data)
    # Output: Float - The maximum value of all the ponts in the line
    #
    def max
      data.map { |point| point.last }.max
    end
    
    
    #
    # Purpose: Scale each point in the line to fit the scale that will be used by the chart
    #
    # Input: 
    # * max_x_value (Float) - The largest x value that is going to be graphed
    # * max_y_value (Float) - The largest y value that is going to be graphed
    # * scale_size (Float) - The scale used as th emaximum size of the graph
    # 
    # Output: None (Each point in @data is scaled)
    #
    def scale_line(max_x_value, max_y_value, scale_size = 100.0)
      @data.each do |point|
        #puts "Line: Scaling #{point[0]} with #{scale_size} and #{max_x_value} to #{scale_size.to_f - ((point[0].to_f * scale_size.to_f) / max_x_value.to_f)}"
        point[0] = scale_size.to_f - ((point[0].to_f * scale_size.to_f) / max_x_value.to_f)
        
        #We are no longer scaling the y value since the range is set on the graph properly now
        #point[1] = (point[1].to_f * scale_size.to_f) / max_y_value.to_f
      end
    end
  end
end