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
		@settings = Nokogiri::XML File.open(SETTINGS_PATH, 'r')
  	@settings.at_xpath('//color').content = color
  	File.open(SETTINGS_PATH, 'w') {|f| @settings.write_xml_to f}
	end

	def set_collection_path
		@settings = Nokogiri::XML File.open(SETTINGS_PATH, 'r')
		current_collection = @settings.at_xpath('//collection').content
		
		unless current_collection == ''
			path = Tk::chooseDirectory initialdir: current_collection, mustexist: true, title: "Select Collection Folder"
		else
			path = Tk::chooseDirectory
		end

		unless path == ''
	  	@settings.at_xpath('//collection').content = path
	  	File.open(SETTINGS_PATH, 'w') {|f| @settings.write_xml_to f}
	  	@collector.collect_files(change=true)
	  end
	end
end