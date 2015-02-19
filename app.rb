require 'sinatra'
require 'faker'
require 'sidekiq'

$stdout.sync = true



module Mailer

  class Worker
    include Sidekiq::Worker

    def perform message
      Mailer.send_mailer_synchronously message
    end
  end


  def self.send_mailer_synchronously(message)
    start_time = Time.now
    puts "Sending Mailer at #{start_time}"

    10.times do
      puts "Sending #{message} to #{Faker::Internet.email} about #{Faker::Company.bs}"
      sleep(rand(2) + 1)
    end

    puts "Finished sending the mailer duration #{Time.now - start_time} seconds"
  end

  def self.send_mailer_asynchronously(message)
    Mailer::Worker.perform_async message
  end

end

get '/' do
  @flash_message = params[:flash]

  erb :index
end

post '/send_mailer_synchronously' do

  Mailer.send_mailer_synchronously params[:message]

  redirect '/?flash=Send%20Sync%20Complete'
end

post '/send_mailer_asynchronously' do

  Mailer.send_mailer_asynchronously params[:message]

  redirect '/?flash=Send%20ASync%20Queued'
end
