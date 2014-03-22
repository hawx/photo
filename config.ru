require './api'
require './web'

map('/api') { run Api }
map('/')    { run Web }
