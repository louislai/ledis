require 'set'

LEDIS_COMMANDS = ['flushdb', 'set', 'get', 'llen', 'rpush',
                  'lpop', 'rpop', 'lrange', 'del',
                  'sadd', 'scard', 'srem', 'smembers']

class Ledis
  attr_accessor :storage, :timestamp

  def initialize
    @storage = {}
    @timestamp = Time.now
  end

  def flushdb
    @storage = {}
    @timestamp = Time.now
    'OK'
  end

  def set(key, value)
    @storage[key] = value
    'OK'
  end

  def get(key)
    @storage[key] || 'EKTYP'
  end

  def del(key)
    @storage.delete(key)
    'OK'
  end

  def sadd(key, *others)
    @storage[key] = Set.new
    others.each { |other| @storage[key].add other }
    'OK'
  end

  def scard(key)
    return 'EKTYP' unless @storage[key]
    @storage[key].size
  end

  def srem(key, *other)
    return 'EKTYP' unless @storage[key]
    others.each { |other| @storage[key].delete other }
    'OK'
  end

  def smembers(key)
    return 'EKTYP' unless @storage[key]
    @storage[key].to_a.join(' ')
  end

  def handle_command(command)
    send(command[0].downcase, *command[1..-1]) if LEDIS_COMMANDS.include? command[0].downcase
  end
end