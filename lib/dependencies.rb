# Internal Dependencies
require 'tk'
require 'tkextlib/bwidget'
require 'nokogiri'
require 'imdb'

# External Dependencies
require 'fullwindow'
require 'button'
require 'collector'

# Constants
SETTINGS_PATH = File.basename(Dir.getwd)+'/../user_data/settings.xml'
MOVIE_DATA_PATH = File.basename(Dir.getwd)+'/../user_data/movie_data.xml'