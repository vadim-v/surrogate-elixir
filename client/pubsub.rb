require 'redis'
require 'irb'

Thread.current[:redis] = Redis.new

class Publisher
  def self.publish(channel, msg)
    Thread.current[:redis].publish(channel, msg)
  end
end

puts 'USAGE: Publisher.publish("topic.1", "Hello there")'
IRB.start
