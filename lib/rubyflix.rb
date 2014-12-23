module Rubyflix
	require 'dependencies'

	def Rubyflix.main
		root = FullWindow.new
		TkLabel.new(root) do
		   text 'Hello, World!'
		   pack { padx 15 ; pady 15; side 'left' }
		end
		Tk.mainloop
	end

end


