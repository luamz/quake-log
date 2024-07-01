class Player
  attr_accessor :id, :name, :kills

  def initialize(id, name)
    @id = id
    @name = name
    @kills = 0
  end
end