LEDIS_COMMANDS = ['flushdb', 'set', 'get', 'llen', 'rpush', 'lpop', 'rpop', 'lrange']

class Ledis
  attr_accessor :storage, :timestamp

  def initialize
    @storage = {}
    @timestamp = Time.now
  end

  def flushdb
    @storage = {}
    @timestamp = Time.now
  end

  def set(key, value)
    @storage[key] = value
    'OK'
  end

  def get(key)
    @storage[key]
  end

  def handle_command(command)
    send(command[0].downcase, *command[1..-1]) if LEDIS_COMMANDS.include? command[0].downcase
  end
end