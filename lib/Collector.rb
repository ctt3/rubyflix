class Collector

	def initialize
		self.collect_files
  end

  def collect_files
		save = Nokogiri::XML File.open(SETTINGS_FILE_PATH, 'r')
  	collection_path = save.at_xpath('//collection').text
  	unless collection_path == ''
  		@files = Dir.glob(collection_path+"/**/*.{mp4,avi,mpg,mkv,m4v,mov}")
  	else
  		@files = []
  	end
  end
end
