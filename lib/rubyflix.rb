module Rubyflix
	require 'dependencies'

	def Rubyflix.main
		root = FullWindow.new
		colorB = Button.new({type: 'color', root: root})
		colorB.pack { padx 150 ; pady 150; side 'left' }
		pathB = Button.new({type: 'collection', root: root})
		pathB.pack { padx 150 ; pady 150; side 'left' }
		Tk.mainloop
	end

end


