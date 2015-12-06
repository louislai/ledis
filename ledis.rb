require 'set'

LEDIS_COMMANDS = ['flushdb', 'set', 'get',
                  'llen', 'rpush', 'lpop', 'rpop', 'lrange', 'del',
                  'sadd', 'scard', 'srem', 'smembers', 'sinter']

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
    return 'EINV' if others.blank?
    @storage[key] = Set.new
    others.each { |other| @storage[key].add other }
    'OK'
  end

  def scard(key)
    return 'EKTYP' unless @storage[key]
    @storage[key].size
  end

  def srem(key, *others)
    return 'EINV' if others.blank?
    return 'EKTYP' unless @storage[key]
    others.each { |other| @storage[key].delete other }
    'OK'
  end

  def smembers(key)
    return 'EKTYP' unless @storage[key]
    @storage[key].to_a.to_json
  end

  def llen(key)
    return 'EKTYP' unless @storage[key]
    @storage[key].size
  end

  def rpush(key, *others)
    return 'EINV' if others.blank?
    @storage[key] ||= []
    others.each { |other| @storage[key] << other }
    @storage[key].size
  end

  def lpop(key)
    return 'EKTYP' unless @storage[key]
    @storage[key].shift
  end

  def rpop(key)
    return 'EKTYP' unless @storage[key]
    @storage[key].pop
  end

  def lrange(key, start, stop)
    return 'EKTYP' unless @storage[key]
    @storage[key][start..stop+1].to_json
  end

  def sinter(*sets)
    return [].to_json if sets.blank?
    sets.reduce(:&).to_json
  end

  def handle_command(command)
    return 'ECOM' unless LEDIS_COMMANDS.include? command[0].downcase
    send(command[0].downcase, *command[1..-1])
  end
end