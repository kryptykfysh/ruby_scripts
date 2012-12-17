#!/usr/bin/env ruby

require 'rubygems'
require 'eventmachine'

class Server
  attr_accessor :connections

  def initialize
    @connections = []
  end

  def start
    @signature = EventMachine.start_server("127.0.0.1", 6667, Connection) do |con|
      con.server = self
    end
  end

  def stop
    EventMachine.stop_server(@signature)

    unless wait_for_connections_and_stop
      EventMachine.add_periodic_timer(1) { wait_for_connections_and_stop }
    end
  end

  def has_username?(name)
    @connections.detect { |connection| connection.name == name }
  end

  private

  def wait_for_connections_and_stop
    if @connections.empty?
      EventMachine.stop
      true
    else
      puts "Waiting for #{@connections.size} connection(s) to stop"
      false
    end
  end
end

class Connection < EventMachine::Connection
  attr_accessor :server
  attr_reader :name
  
  def initialize
    @name = nil
  end

  def post_init
    send_data("Hi, please enter your name: ")
  end

  def receive_data(data)
    data.strip!

    unless @name
      handle_login(data)
    else
      handle_message(data)
    end
  end

  def unbind
    @server.connections.each { |connection| connection.send_data("#{@name} has just left\n") }
    @server.connections.delete(self)
  end

  private

  def handle_login(name)
    if @server.has_username? name
      send_data("Sorry, that username has already been taken. Please choose another: ")
      return
    end

    send_data("Hello #{name}\n")

    others = @server.connections

    if others.count > 0
      send_data("There are #{@server.connections.count} other people chatting at the moment\n")

      other_names = others.collect { |other| other.name }
      send_data("Currently connected are: #{other_names.join(", ")}\n")
    else
      send_data("There's nobody else here right now!\n")
    end

    send_data("-------------------------------------------------------------------------------------\n")
    @name = name

    @server.connections.each { |connection| connection.send_data("#{@name} has just joined\n") }
    @server.connections << self
  end

  def handle_message(message)
    message = "<#{@name}> #{message}\n"
    @server.connections.each { |connection| connection.send_data(message) unless connection == self }
  end
end

EventMachine::run do
  s = Server.new
  s.start
  puts "Server listening"
end