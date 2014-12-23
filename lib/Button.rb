class Button < TkButton

	def initialize(*args, dict)
		super(*args)
		@root = dict[:root]
		@collector = dict[:collector]
		self.new(dict[:type])
	end

	def new(type)
		case type
		when 'color'
			self.text = "Select Color"
			self.command = proc{set_root_color}
		when 'collection'
			self.text = "Set Collection Path"
			self.command = proc{set_collection_path}
		end
	end

	def set_root_color
		color = Tk::chooseColor initialcolor: @root.bg
		@root.bg = color
		save = Nokogiri::XML File.open(SETTINGS_FILE_PATH, 'r')
  	save.at_xpath('//color').content = color
  	File.open(SETTINGS_FILE_PATH, 'w') {|f| save.write_xml_to f}
	end

	def set_collection_path
		path = Tk::chooseDirectory
		save = Nokogiri::XML File.open(SETTINGS_FILE_PATH, 'r')
  	save.at_xpath('//collection').content = path
  	File.open(SETTINGS_FILE_PATH, 'w') {|f| save.write_xml_to f}
  	@collector.collect_files
	end
end