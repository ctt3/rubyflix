class Collector

	def initialize
		@settings = Nokogiri::XML File.open(SETTINGS_PATH, 'r')
		@movie_data = Nokogiri::XML File.open(MOVIE_DATA_PATH, 'r')
		if first_time?
			self.collect_first_time
		else
			self.collect_files
		end
  end

  def collect_first_time
		@init_win = TkRoot.new
		@init_win.title = "RubyFlix: Initial Load"
		# choose directory button
		# on complete, label with how many found
		# and update with progress bar
		# on complete close and begin.
		collector = self
		@path_button = TkButton.new(@init_win){
			text 'Select Collection Folder'
			command( proc {collector.set_initial_collection_path})
		}
		@path_button.pack

		Tk.mainloop
	end

	def set_initial_collection_path
		path = Tk::chooseDirectory mustexist: true, title: "Select Collection Folder"
		unless path == ''
  		@files = Dir.glob(path+"/**/*.{mp4,avi,mpg,mkv,m4v,mov}")
	  	@settings.at_xpath('//collection').content = path
  		@settings.at_xpath('//collection-size').content = @files.size
	  	File.open(SETTINGS_PATH, 'w') {|f| @settings.write_xml_to f}
	  	@path_button.pack_forget

  		titles = @files.map{|f| f.split('/')[-1].split('.')[0]}
  		self.collect_movies(titles)
	  end
	end

  def first_time?
  	# Is this the first time running the program?
  	if @settings.at_xpath('//initial').text == "true"
  		true
  	else
  		false
  	end
  end

  def same_title? (title_A, title_B)
  	# Are the movie titles close enough to be considered the same?
  	title_A.gsub(/[^0-9A-Za-z]/, '').downcase.eql? title_B.gsub(/[^0-9A-Za-z]/, '').downcase
  end


  def collect_files(change=false)
  	# Get file paths from directory
  	collection_path = @settings.at_xpath('//collection').text
  	@files = []
  	unless collection_path == ''
  		@files = Dir.glob(collection_path+"/**/*.{mp4,avi,mpg,mkv,m4v,mov}")
  	end
  	old_size = @settings.at_xpath('//collection-size').text.to_i
  	new_size = @files.size
  	@size_change = (new_size != old_size)
  	if change and @size_change
  		@settings.at_xpath('//collection-size').content = @files.size
  		File.open(SETTINGS_PATH, 'w') {|f| @settings.write_xml_to f}

  		to_delete, to_add = self.collect_changes
  		self.remove_movies(to_delete)
  		self.collect_movies(to_add)
  	end
  end

  def collect_changes(titles)
  	# Decide what is new and what is old
		@movie_data = Nokogiri::XML File.open(MOVIE_DATA_PATH, 'r')
		collected_titles = @movie_data.xpath("//movie/title").map{|n| n.content}
		
		return [],[]
  	# puts @size_change
  # 	@less_movies = @files - 
  # 	@more_movies = 

  end

  def remove_movies(titles)
  	# Remove no longer used titles from xml
  end

  def write_to_xml(movie)
  	# Create XML in this method
		@movie_data = Nokogiri::XML File.open(MOVIE_DATA_PATH, 'r')
  	collection_node = @movie_data.at_xpath('//collection')
  	movie_node = Nokogiri::XML::Node.new "movie", @movie_data
  	collection_node << movie_node
  	# Create Nodes
  	title_node = Nokogiri::XML::Node.new "title", @movie_data
  	year_node = Nokogiri::XML::Node.new "year", @movie_data
  	director_node = Nokogiri::XML::Node.new "director", @movie_data
  	rating_node = Nokogiri::XML::Node.new "rating", @movie_data
  	runtime_node = Nokogiri::XML::Node.new "runtime", @movie_data
  	summary_node = Nokogiri::XML::Node.new "summary", @movie_data
  	poster_node = Nokogiri::XML::Node.new "poster-path", @movie_data
  	trailer_node = Nokogiri::XML::Node.new "trailer-url", @movie_data
  	genres_node = Nokogiri::XML::Node.new "genres", @movie_data
  	cast_node = Nokogiri::XML::Node.new "cast", @movie_data
  	path_node = Nokogiri::XML::Node.new "file-path", @movie_data
  	# Insert Content
  	title_node.content = movie.title.split('(')[0].strip
  	year_node.content = movie.year
  	director_node.content = movie.director[0]
  	rating_node.content = movie.rating
  	runtime_node.content = movie.length
  	summary_node.content = movie.plot_summary
  	poster_node.content = movie.poster
  	trailer_node.content = movie.trailer_url
  	(0...movie.cast_members.length).each do |i|
  		if i > 4 then break end
  		actor = movie.cast_members[i]
  		actor_node = Nokogiri::XML::Node.new "actor", @movie_data
  		actor_node.content = actor
  		cast_node << actor_node
  	end
  	(0...movie.genres.length).each do |i|
  		if i > 4 then break end
  		genre = movie.genres[i]
  		genre_node = Nokogiri::XML::Node.new "genre", @movie_data
  		genre_node.content = genre
  		genres_node << genre_node
  	end
  	# Add children nodes to movie_node
  	[title_node, year_node, director_node, rating_node, runtime_node, summary_node, poster_node, trailer_node, genres_node, cast_node, path_node].each do |node|
  		movie_node << node
  	end
  	File.open(MOVIE_DATA_PATH, 'w') {|f| @movie_data.write_xml_to f}
  end

  def collect_movies(titles)
  	# Search and find movie objects from IMDB by title
  	if @init_win
  		progressBar = Tk::BWidget::ProgressBar.new(@init_win)
  	else
			@progress_win = TkRoot.new
			@progress_win.title = "RubyFlix: Loading Movies"
  		progressBar = Tk::BWidget::ProgressBar.new(@progress_win)
			@progress_win.mainloop
  	end
		progress = TkVariable.new
		progressBar.variable = progress
		progress.value = 0
		progressBar.maximum = 100
		progressBar.pack

		total_titles = titles.size
		bad_result,no_result = 0,0
		for i in (0...total_titles)
			search_title = titles[i].encode('UTF-8')
			search_results = Imdb::Search.new(search_title)
			unless search_results.movies.empty?
				movie_title = search_results.movies[0].title.split('(')[0].strip.encode('UTF-8')
				unless self.same_title?(movie_title, search_title)
					bad_result += 1
					# puts "No Match: search- #{search_title} | result- #{movie_title}"
				else
					self.write_to_xml(search_results.movies[0])
				end
			else
				no_result += 1
				# puts "No Result: search- #{search_title} | result- #{movie_title}"
			end
			progress.value = ((i.to_f/total_titles.to_f)*100).to_i
			puts "#{i}/#{total_titles}"
		end
		puts "BAD RESULTS: #{bad_result}/#{total_titles}"
		puts "NO RESULTS: #{no_result}/#{total_titles}"
  end
end