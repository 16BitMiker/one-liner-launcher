#!/usr/bin/env ruby
#          _ _                               _ _         
#    /\/\ (_) | _____ _ __    /\/\   ___  __| (_) __ _   
#   /    \| | |/ / _ \ '__|  /    \ / _ \/ _` | |/ _` |  
#  / /\/\ \ |   <  __/ |    / /\/\ \  __/ (_| | | (_| |  
#  \/    \/_|_|\_\___|_|    \/    \/\___|\__,_|_|\__,_|  
#   
# One Liner Launcher v0.1
# by https://miker.media

require 'colorize'
require 'strscan'
require 'table_print'

class MikerCodes

	def initialize
	
		@perl = []
		@ruby = []
		
		@curl = <<~"CURL".gsub(%r~\n~, %q| |)
			curl
			--fail
			--silent
			--show-error
			--location
			\x27https://miker.codes/%s\x27
		CURL
	
	end
	
	def run
	
		self.parseHTML
	
		loop do 
		
			print %q|> ruby / perl / quit?: |.blue
			
			chosen = %q||
			
			case gets.chomp!.gsub(%r~\s+~, %q||)
			when %r~^r(?:uby)?$~i
				tp @ruby
				chosen = %q|@ruby|
			when %r~^p(?:erl)?$~i
				tp @perl
				chosen = %q|@perl|
			when %r~^q(?:uit)?$~i
				puts %q|> quitting!|.red 
				exit 0
			else 
				puts %q|> nothing selected...|.red
				next
			end
			
			puts  %q|-|*39
			print %q|> select: |.blue
			go = gets.chomp!
			
			case go
			when %r~q(?:uit)?~i
				puts %q|quiting!|.red 
				exit 0
			when %r~\d+~
				if chosen.match(%r~perl~i) then
					self.runCode(chosen,go)
				elsif chosen.match(%r~ruby~i) then
					self.runCode(chosen,go)
				else
					puts %q|> error so quitting!|.red
					exit 69
				end
			else
				puts %q|> nothing selected so re-doing...|.red
			end
		end
	end
	
	private
	
	def parseHTML()
	
		html = %x|#{@curl % %q||}|.gsub(%r~\n~, %q| |).gsub(%r~\s+~,%q| |)
		
		s = StringScanner.new(html)
		
		re = %r~alt="\[TXT\]"></a></td><td><a href="~
		
		until s.eos? || s.check_until(re).nil?
			
			s.skip_until(re)
			if s.check(%r~[^"]+\.sh(?=")~) then
				type = ''
				if s.check(%r~pl[^"]+\.sh(?=")~) then
					type = %q|@perl|
				else
					type = %q|@ruby|
				end
				
				row = {}
				row = { choice: (instance_variable_get type).length, files: s.scan_until(%r~(?=")~) }
				
				(instance_variable_get type).push( row )
			end
		end
	end
	
	def runCode(chosen, n)
		
		n = n.to_i
		
		ol = instance_variable_get(chosen)[n][:files]
		
		# redunant
		curl = %Q`#{@curl % ol}`.gsub(%r~(\n)|\s{2,}~) { $1 ? %q|| : %q| | }
		
		puts %Q|> downloading...|
		puts %Q|> #{curl}|.yellow
		code = %x|#{curl}|.gsub(%r~^\#.*|\n~,%q||)
		
		puts %Q|> running...|
		puts %Q|> #{code}|.yellow
		system (code)
		
	end
end

run = MikerCodes.new
run.run

__END__
Notes:

ways to run bash commands:

method 1: | bash /dev/stdin 
	~ example: #{@curl % ol} | bash -i /dev/stdin

method 2: bash <(...) 
	~ example: bash -i <(#{@curl % ol})