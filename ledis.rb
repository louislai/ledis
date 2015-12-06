require 'set'

LEDIS_COMMANDS = ['flushdb', 'expire', 'ttl', 'del',
                  'set', 'get',
                  'llen', 'rpush', 'lpop', 'rpop', 'lrange',
                  'sadd', 'scard', 'srem', 'smembers', 'sinter']

class Ledis
  attr_accessor :storage, :timestamp

  def initialize
    @storage = {}
    @expiry = {}
  end

  def flushdb
    @storage = {}
    'OK'
  end

  def expire(key, seconds)
    @expiry[key] = Time.at(Time.now.to_i + seconds.to_i)
    'OK'
  end

  def ttl(key)
    return 0 unless @storage[key]
    (Time.now - @expiry[key]).to_i
    1
  end

  def set(key, value)
    @storage[key] = value
    'OK'
  end

  def get(key)
    @storage[key] || 'EKTYP'
  end

  def del(key)
    clean_key(key)
    'OK'
  end

  def sadd(key, *others)
    return 'EINV' if others.empty?
    @storage[key] ||= Set.new
    others.each { |other| @storage[key].add other }
    'OK'
  end

  def scard(key)
    return 'EKTYP' unless @storage[key]
    @storage[key].size
  end

  def srem(key, *others)
    return 'EINV' if others.empty?
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
    return 'EINV' if others.empty?
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
    return [].to_json if sets.empty?
    sets.reduce(:&).to_json
  end

  def handle_command(command)
    clean_expired
    return 'ECOM' unless LEDIS_COMMANDS.include? command[0].downcase
    send(command[0].downcase, *command[1..-1])
  end

  private
  def clean_key(key)
    @storage.delete(key)
    @expiry.delete(key)
  end

  def clean_expired
    keys_to_delete = []
    @expired.each do |key, value|
      keys_to_delete << key if value < Time.now
    end
    keys_to_delete.each { |key| clean_key(key) }
  end
end