class Ledis
  attr_accessor :storage, :timestamp

  def initialize
    @storage = {}
    @timestamp = Time.now
  end
end