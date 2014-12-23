class FullWindow < TkRoot

	def initialize(*args)
		super(*args)
		self.new
	end

	def new
		self.title "Hello, World!"
		self.width = self.winfo_screenwidth
		self.height = self.winfo_screenheight
    self.overrideredirect(1)
    self['geometry'] = "#{width}x#{height}+0+0"
    self.takefocus # <-- move focus to this widget
    self.bind("Escape", proc{self.destroy})

		save = Nokogiri::XML File.open(SETTINGS_FILE_PATH, 'r')
  	color = save.at_xpath('//color').text
  	self.bg = (color == '' ? self.bg : color)
  end
end