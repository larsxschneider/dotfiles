#!/usr/bin/env ruby
#
# Source: https://gist.github.com/185789
#

require 'socket'

# Its Navajo, not Apache!
class Navajo
  
  @@mime_types = Hash.new
  @@mime_types[/\.html$/] = 'text/html'
  @@mime_types[/\.png$/] = 'image/png'
  @@mime_types[/\.jpe?g$/] = 'image/jpeg'
  @@mime_types[/\.(rb|sh|txt|c|cpp|h|pl|php|css|conf)$|^.*\/[^\.]+?$/] = 'text/plain'
  
  @@error_texts = Hash.new
  @@error_texts[403] = 'Forbidden'
  @@error_texts[404] = 'Not Found'
  @@error_texts[406] = 'Not Acceptable'
  @@error_texts[500] = 'Internal Error'
  @@error_texts[501] = 'Not Implemented'
  
  
  # starts the server and delegates the connections to another method
  def run( port, document_root )
    
    begin
      # get the absolute path
      @document_root = File.expand_path( document_root )
      
      unless File.directory? @document_root
        raise document_root + ' is not a directory!'   
      end
      
      # start our server to handle connections (will raise things on errors)
      @socket = TCPServer.new( port )
      
      inform "serving '#{@document_root}' on port #{port}"
      
      # to get socket.print working our in way
      $\ = "\r\n"
      
      # handle every request with another method
      while true
        s = @socket.accept
        
        Thread.new(s) do |r|
          handle_request r
        end
      end
      
    # ctrl-c
    rescue Interrupt
      inform 'got interrupt..'
      
    # get all possibly errors
    rescue => e
      inform e.class.to_s + ': ' + e.message
      
    # ensure that we release the socket on errors
    ensure
      if @socket
        @socket.close
        inform 'socked closed..'
      end
      
      inform 'quiting.'
      
    end
  end
  
  # handles every request :)
  def handle_request( socket )
    # get the first (request) line
    request_line = socket.readline
    
    # check the requst line and catch the request-path in $1
    if request_line =~ %r{^GET (/.*?)/* HTTP/1\.[10]\r\n$}
      
      # unpack url-encoding (0-bytes are evil)
      requested_file = $1.gsub('%00', '')
      requested_file.gsub!(/%[a-fA-F0-9]{2}/) { |c| c[1..2].hex.chr }
      
      # because we need this after serving the request.
      orginal_requested_file = requested_file
      
      # build the absolute requested path
      requested_file = File.expand_path( @document_root+requested_file )
      
      inform "#{orginal_requested_file} got requested from #{socket.inspect}"
      
      # check if someone tries ".." or if the file isn't readable
      if requested_file[0..(@document_root.size() - 1)] != @document_root or
        ( File.exists? requested_file and not File.readable? requested_file )
        send_error( 403, socket )
        
      # check for 404
      elsif not File.exists? requested_file
        if( File.exists? requested_file.gsub( /\.tar$/, '' ) and
          File.directory? requested_file.gsub( /\.tar$/, '' ) )
          send_as_tar( requested_file.gsub( /\.tar$/, '' ), socket )
          
        else
          send_error( 404, socket )
        end
        
      # lets see if its a folder
      elsif File.directory? requested_file
        socket.print "HTTP/1.0 200 OK" 
        socket.print "Content-Type: text/html\r\n"
        
        # print a pretty list
        socket.print "<ul>"
        Dir.foreach( requested_file ) do | file |
          if File.directory? requested_file + '/' + file
            socket.print "<li><a href=\"#{file}/\">#{file}/</a></li>"
          else
            socket.print "<li><a href=\"#{file}\">#{file}</a></li>"
          end
        end
        socket.print "</ul>"
        
      # if it isn't a regular file (fifos, devices, etc)
      elsif not File.file? requested_file
        send_error( 406, socket )
        
      # ok, it seems to be a existing, readable file, lets try it..
      else
        socket.print "HTTP/1.0 200 OK"
        socket.print "Content-Type: #{get_mime_type( requested_file )}\r\n"
        #socket.print "Content-Length: #{File.size requested_file}\r\n"
        
        #inform "Content-Length: #{File.size requested_file}\r\n"

        
        # send 4kb blocks (seems to perform optimal)
        f = File.open( requested_file, 'r')
        while( block = f.read(4*1024) )
          socket.write block
        end
        f.close
      end
      
      inform '    finished ' + orginal_requested_file
      
    else
      # if we did not get a proper GET request > 501
      send_error( 501, socket )
    end
    
    # close the client socket
    socket.close
  end
  
  # print our errors/informations in stderr
  def inform( about_what )
    $stderr.puts about_what
  end
  
  def send_error( number, socket )
    number = 500  unless @@error_texts.has_key? number
    
    socket.print "HTTP/1.0 #{number} #{@@error_texts[number]}" 
    socket.print "Content-Type: text/html\r\n"
    socket.print "<h1>##{number}: #{@@error_texts[number]}</h1>"
  end
  
  def get_mime_type( filename )
    @@mime_types.each_key do |regex|
      # always claim its utf-8
      return @@mime_types[regex]+'; charset=utf-8'   if filename =~ regex
    end
    
    return 'application/octet-stream'
  end
  
  # sends directories as tar file
  def send_as_tar( file, socket )
    inform '    invoking tar'
    socket.print "HTTP/1.0 200 OK" 
    socket.print('Content-Disposition: attachment;' +
        %Q{ filename="#{file.gsub(%r{/+$|"},'').gsub(%r{.*/},'')}.tar"})
    socket.print "Content-Type: application/x-tar\r\n"
    
    tar = open("|tar cC '#{file.gsub("'", "'\\\\''")}' .", 'r')
    
    while( block = tar.read(4*1024) )
      socket.write block
    end
    
    tar.close
    
  end
  
end


# get parameters and start the server
if ARGV.empty?
  port = 8008
  root = "~/pub"
  
elsif ARGV.size == 1
  port = 8008
  root = ARGV[0]
  
elsif ARGV.size == 2
  port = ARGV[0].to_i
  port = 1   if port <= 0
  root = ARGV[1]
  
else
  puts 'Usage: navajo.rb [port] [document_root]'
  exit -1
  
end

Navajo.new().run( port, root )
