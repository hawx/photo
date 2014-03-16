require 'dm-core'
require 'dm-migrations'
require 'dm-types'
require 'dm-sqlite-adapter'

require_relative 'data/photo'
require_relative 'data/tag'
require_relative 'data/tagging'

DataMapper.setup(:default, "sqlite://#{Dir.pwd}/photo.db")
DataMapper.auto_upgrade!
