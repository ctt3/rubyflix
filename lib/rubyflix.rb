module Rubyflix
	require 'dependencies'

	def Rubyflix.main
		collector = Collector.new
		root = FullWindow.new
		colorB = Button.new({type: 'color', root: root})
		colorB.pack { padx 150 ; pady 150; side 'left' }
		pathB = Button.new({type: 'collection', collector: collector})
		pathB.pack { padx 150 ; pady 150; side 'left' }
		Tk.mainloop
	end

end


