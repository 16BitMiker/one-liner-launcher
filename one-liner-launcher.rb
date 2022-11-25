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
  attr_reader :language_files

  def initialize
    @language_files = {
      perl: [],
      ruby: []
    }

    @curl = <<-"CURL".gsub(%r~^\s+|\t+|(\n)~) { $1 ? %q| | : %q|| }
      curl
      --fail
      --silent
      --show-error
      --location
      \x27https://miker.codes/%s\x27
    CURL
  end

  def run
    parseHTML

    loop do
      print %q|> ruby / perl / quit?: |.blue

      chosen = %q||

      case gets.chomp!.gsub(%r~\s+~, %q||)
      when %r~^r(?:uby)?$~i
        tp language_files[:ruby]
        chosen = :ruby
      when %r~^p(?:erl)?$~i
        tp language_files[:perl]
        chosen = :perl
      when %r~^q(?:uit)?$~i
        puts %q|> quitting!|.red
        exit 69
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
        exit 69
      when %r~\d+~
        if [:perl, :ruby].include?(chosen)
          run_code(chosen, go)
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

  def parseHTML
    html = %x|#{@curl % %q||}|.gsub(%r~\n~, %q| |).gsub(%r~\s+~,%q| |)

    s = StringScanner.new(html)

    re = %r~alt="\[TXT\]"></a></td><td><a href="~

    until s.eos? || s.check_until(re).nil?
      s.skip_until(re)
      if s.check(%r~[^"]+\.sh(?=")~)
        lang = if s.check(%r~pl[^"]+\.sh(?=")~)
          :perl
        else
          :ruby
        end

        row = { choice: language_files[lang].length, files: s.scan_until(%r~(?=")~) }

        language_files[lang].push(row)
      end
    end
  end

  def run_code(chosen, num)
    num = num.to_i

    ol = language_files[chosen][num][:files]

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
