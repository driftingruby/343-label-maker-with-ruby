require 'rufus/scheduler'

scheduler = Rufus::Scheduler.new

scheduler.every '1m' do
  Twitter.fetch if ENV['WORKER']
end