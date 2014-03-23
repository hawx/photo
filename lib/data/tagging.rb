class Tagging
  include DataMapper::Resource

  belongs_to :tag,   key: true
  belongs_to :photo, key: true
end

class MachineTagging
  include DataMapper::Resource

  belongs_to :machine_tag, key: true
  belongs_to :photo,       key: true
end
