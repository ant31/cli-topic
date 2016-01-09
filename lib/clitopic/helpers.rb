# encoding: utf-8


#"The MIT License (MIT)

# Copyright © Heroku 2008 - 2014

# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:

# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
# CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
# TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE."
require 'fileutils'
module Clitopic
  module Helpers

    extend self

    def home_directory
      Dir.home
    end

    def display(msg="", new_line=true)
      if new_line
        puts(msg)
      else
        print(msg)
      end
      $stdout.flush
    end

    def redisplay(line, line_break = false)
      display("\r\e[0K#{line}", line_break)
    end

    def deprecate(message)
      display "WARNING: #{message}"
    end

    def debug(*args)
      $stderr.puts(*args) if debugging?
    end

    def stderr_puts(*args)
      $stderr.puts(*args)
    end

    def stderr_print(*args)
      $stderr.print(*args)
    end

    def debugging?
      ENV['CLITOPIC_DEBUG']
    end

    def confirm(message="Are you sure you wish to continue? (y/n)")
      display("#{message} ", false)
      ['y', 'yes'].include?(ask.downcase)
    end

    def confirm_command(app_to_confirm = app, message=nil)
      if confirmed_app = Clitopic::Commands.current_options[:confirm]
        unless confirmed_app == app_to_confirm
          raise(Clitopic::Commands::CommandFailed, "Confirmed app #{confirmed_app} did not match the selected app #{app_to_confirm}.")
        end
        return true
      else
        display
        message ||= "WARNING: Destructive Action\n"
        message << "\nTo proceed, type \"#{app_to_confirm}\" or re-run this command with --confirm #{app_to_confirm}"
        output_with_bang(message)
        display
        display "> ", false
        if ask.downcase != app_to_confirm
          error("Confirmation did not match #{app_to_confirm}. Aborted.")
        else
          true
        end
      end
    end

    def format_date(date)
      date = Time.parse(date).utc if date.is_a?(String)
      date.strftime("%Y-%m-%d %H:%M %Z").gsub('GMT', 'UTC')
    end

    def ask
      $stdin.gets.to_s.strip
    end

    def shell(cmd)
      FileUtils.cd(Dir.pwd) {|d| return `#{cmd}`}
    end

    def run_command(command, args=[])
      Clitopic::Command.run(command, args)
    end


    def time_ago(since)
      if since.is_a?(String)
        since = Time.parse(since)
      end

      elapsed = Time.now - since

      message = since.strftime("%Y/%m/%d %H:%M:%S")
      if elapsed <= 60
        message << " (~ #{elapsed.floor}s ago)"
      elsif elapsed <= (60 * 60)
        message << " (~ #{(elapsed / 60).floor}m ago)"
      elsif elapsed <= (60 * 60 * 25)
        message << " (~ #{(elapsed / 60 / 60).floor}h ago)"
      end
      message
    end

    def time_remaining(from, to)
      secs = (to - from).to_i
      mins  = secs / 60
      hours = mins / 60
      return "#{hours}h #{mins % 60}m" if hours > 0
      return "#{mins}m #{secs % 60}s" if mins > 0
      return "#{secs}s" if secs >= 0
    end

    def truncate(text, length)
      return "" if text.nil?
      if text.size > length
        text[0, length - 2] + '..'
      else
        text
      end
    end

    @@kb = 1024
    @@mb = 1024 * @@kb
    @@gb = 1024 * @@mb
    def format_bytes(amount)
      amount = amount.to_i
      return '(empty)' if amount == 0
      return amount if amount < @@kb
      return "#{(amount / @@kb).round}k" if amount < @@mb
      return "#{(amount / @@mb).round}M" if amount < @@gb
      return "#{(amount / @@gb).round}G"
    end

    def quantify(string, num)
      "%d %s" % [ num, num.to_i == 1 ? string : "#{string}s" ]
    end

    def has_git_remote?(remote)
      git('remote').split("\n").include?(remote) && $?.success?
    end

    def create_git_remote(remote, url)
      return if has_git_remote? remote
      git "remote add #{remote} #{url}"
      display "Git remote #{remote} added" if $?.success?
    end

    def longest(items)
      items.map { |i| i.to_s.length }.sort.last
    end

    def display_table(objects, columns, headers)
      lengths = []
      columns.each_with_index do |column, index|
        header = headers[index]
        lengths << longest([header].concat(objects.map { |o| o[column].to_s }))
      end
      lines = lengths.map {|length| "-" * length}
      lengths[-1] = 0 # remove padding from last column
      display_row headers, lengths
      display_row lines, lengths
      objects.each do |row|
        display_row columns.map { |column| row[column] }, lengths
      end
    end

    def display_row(row, lengths)
      row_data = []
      row.zip(lengths).each do |column, length|
        format = column.is_a?(Fixnum) ? "%#{length}s" : "%-#{length}s"
        row_data << format % column
      end
      display(row_data.join("  "))
    end

    def json_encode(object)
      JSON.generate(object)
    end

    def json_decode(json)
      JSON.parse(json)
    rescue JSON::ParserError
      nil
    end

    def set_buffer(enable)
      with_tty do
        if enable
          `stty icanon echo`
        else
          `stty -icanon -echo`
        end
      end
    end

    def with_tty(&block)
      return unless $stdin.isatty
      begin
        yield
      rescue
        # fails on windows
      end
    end

    def get_terminal_environment
      { "TERM" => ENV["TERM"], "COLUMNS" => `tput cols`.strip, "LINES" => `tput lines`.strip }
    rescue
      { "TERM" => ENV["TERM"] }
    end

    def fail(message)
      raise Clitopic::Commands::CommandFailed, message
    end

    ## DISPLAY HELPERS

    def action(message, options={})
      display("#{in_message(message, options)}... ", false)
      Clitopic::Helpers.error_with_failure = true
      ret = yield
      Clitopic::Helpers.error_with_failure = false
      display((options[:success] || "done"), false)
      if @status
        display(", #{@status}", false)
        @status = nil
      end
      display
      ret
    end

    def in_message(message, options={})
      message = "#{message} in space #{options[:space]}" if options[:space]
      message = "#{message} in organization #{org}" if options[:org]
      message
    end

    def status(message)
      @status = message
    end

    def format_with_bang(message)
      return '' if message.to_s.strip == ""
      " !    " + message.split("\n").join("\n !    ")
    end

    def output_with_bang(message="", new_line=true)
      return if message.to_s.strip == ""
      display(format_with_bang(message), new_line)
    end

    def error(message, report=false)
      if Clitopic::Helpers.error_with_failure
        display("failed")
        Clitopic::Helpers.error_with_failure = false
      end
      $stderr.puts(format_with_bang(message))
      exit(1)
    end

    def self.error_with_failure
      @@error_with_failure ||= false
    end

    def self.error_with_failure=(new_error_with_failure)
      @@error_with_failure = new_error_with_failure
    end

    def self.included_into
      @@included_into ||= []
    end

    def self.extended_into
      @@extended_into ||= []
    end

    def self.included(base)
      included_into << base
    end

    def self.extended(base)
      extended_into << base
    end

    def display_header(message="", new_line=true)
      return if message.to_s.strip == ""
      display("=== " + message.to_s.split("\n").join("\n=== "), new_line)
    end

    def display_object(object)
      case object
      when Array
        # list of objects
        object.each do |item|
          display_object(item)
        end
      when Hash
        # if all values are arrays, it is a list with headers
        # otherwise it is a single header with pairs of data
        if object.values.all? {|value| value.is_a?(Array)}
          object.keys.sort_by {|key| key.to_s}.each do |key|
            display_header(key)
            display_object(object[key])
            hputs
          end
        end
      else
        hputs(object.to_s)
      end
    end

    def hputs(string='')
      Kernel.puts(string)
    end

    def hprint(string='')
      Kernel.print(string)
      $stdout.flush
    end

    def spinner(ticks)
      %w(/ - \\ |)[ticks % 4]
    end

    def launchy(message, url)
      action(message) do
        require("launchy")
        launchy = Launchy.open(url)
        if launchy.respond_to?(:join)
          launchy.join
        end
      end
    end

    # produces a printf formatter line for an array of items
    # if an individual line item is an array, it will create columns
    # that are lined-up
    #
    # line_formatter(["foo", "barbaz"])                 # => "%-6s"
    # line_formatter(["foo", "barbaz"], ["bar", "qux"]) # => "%-3s   %-6s"
    #
    def line_formatter(array)
      if array.any? {|item| item.is_a?(Array)}
        cols = []
        array.each do |item|
          if item.is_a?(Array)
            item.each_with_index { |val,idx| cols[idx] = [cols[idx]||0, (val || '').length].max }
          end
        end
        cols.map { |col| "%-#{col}s" }.join("  ")
      else
        "%s"
      end
    end

    def styled_array(array, options={})
      fmt = line_formatter(array)
      array = array.sort unless options[:sort] == false
      array.each do |element|
        display((fmt % element).rstrip)
      end
      display
    end

    def format_error(error, message='Clitopic client internal error.')
      formatted_error = []
      formatted_error << " !    #{message}"
      formatted_error << " !    Search for help at: #{Clitopic.help_page || "https://github.com/ant31/cli-topic/wiki"}"
      formatted_error << " !    Or report a bug at: #{Clitopic.issue_report || "https://github.com/ant31/cli-topic/issues/new"} "
      formatted_error << ''

      command = ARGV.map do |arg|
        if arg.include?(' ')
          arg = %{"#{arg}"}
        else
          arg
        end
      end.join(' ')
      formatted_error << "    Command:     #{command}"

      if http_proxy = ENV['http_proxy'] || ENV['HTTP_PROXY']
        formatted_error << "    HTTP Proxy: #{http_proxy}"
      end
      if https_proxy = ENV['https_proxy'] || ENV['HTTPS_PROXY']
        formatted_error << "    HTTPS Proxy: #{https_proxy}"
      end
      formatted_error << "    Version:     #{Clitopic.version}"
      formatted_error << "    Error:       #{error.message} (#{error.class})"
      formatted_error << "    Backtrace:\n"  + "#{error.backtrace.join("\n")}".indent(17) unless error.backtrace.nil?
      formatted_error << "\n"
      formatted_error << "    More information in #{error_log_path}"
      formatted_error << "\n"
      formatted_error.join("\n")
    end

    def styled_error(error, message='Clitopic client internal error.')
      if Clitopic::Helpers.error_with_failure
        display("failed")
        Clitopic::Helpers.error_with_failure = false
      end
      error_log(message, error.message, error.backtrace.join("\n"))
      $stderr.puts(format_error(error, message))
    rescue => e
      $stderr.puts e, e.backtrace, error, error.backtrace
    end

    def error_log(*obj)
      FileUtils.mkdir_p(File.dirname(error_log_path))
      File.open(error_log_path, 'a') do |file|
        file.write(obj.join("\n") + "\n")
      end
    end

    def find_default_file
      file = nil
      Clitopic.default_files.each do |f|
        if File.exist?(f)
          file = f
          break
        end
      end
      return file
    end

    def error_log_path
      File.join(home_directory, '.clitopic', 'error.log')
    end

    def styled_header(header)
      display("=== #{header}")
    end

    def styled_hash(hash, keys=nil)
      max_key_length = hash.keys.map {|key| key.to_s.length}.max + 2
      keys ||= hash.keys.sort {|x,y| x.to_s <=> y.to_s}
      keys.each do |key|
        case value = hash[key]
        when Array
          if value.empty?
            next
          else
            elements = value.sort {|x,y| x.to_s <=> y.to_s}
            display("#{key}: ".ljust(max_key_length), false)
            display(elements[0])
            elements[1..-1].each do |element|
              display("#{' ' * max_key_length}#{element}")
            end
            if elements.length > 1
              display
            end
          end
        when nil
          next
        else
          display("#{key}: ".ljust(max_key_length), false)
          display(value)
        end
      end
    end

    def string_distance(first, last)
      distances = [] # 0x0s
      0.upto(first.length) do |index|
        distances << [index] + [0] * last.length
      end
      distances[0] = 0.upto(last.length).to_a
      1.upto(last.length) do |last_index|
        1.upto(first.length) do |first_index|
          first_char = first[first_index - 1, 1]
          last_char = last[last_index - 1, 1]
          if first_char == last_char
            distances[first_index][last_index] = distances[first_index - 1][last_index - 1] # noop
          else
            distances[first_index][last_index] = [
              distances[first_index - 1][last_index],     # deletion
              distances[first_index][last_index - 1],     # insertion
              distances[first_index - 1][last_index - 1]  # substitution
            ].min + 1 # cost
            if first_index > 1 && last_index > 1
              first_previous_char = first[first_index - 2, 1]
              last_previous_char = last[last_index - 2, 1]
              if first_char == last_previous_char && first_previous_char == last_char
                distances[first_index][last_index] = [
                  distances[first_index][last_index],
                  distances[first_index - 2][last_index - 2] + 1 # transposition
                ].min
              end
            end
          end
        end
      end
      distances[first.length][last.length]
    end

    def display_suggestion(actual, possibilities, allowed_distance=4)
      suggestions = suggestion(actual, possibilities, allowed_distance)
      if suggestions.length == 1
        "Perhaps you meant:\n" + suggestions.first.indent(20)
      elsif suggestions.length > 1
        "Perhaps you meant:\n" + "#{suggestions.map {|suggestion| "- #{suggestion}"}.join("\n").indent(2)}."
      else
        nil
      end
    end

    def suggestion(actual, possibilities, allowed_distance=4)
      distances = Hash.new {|hash,key| hash[key] = []}
      begin_with = []
      possibilities.each do |suggestion|
        if suggestion.start_with?(actual)
          distances[0] << suggestion
        else
          distances[string_distance(actual, suggestion)] << suggestion
        end
      end

      minimum_distance = distances.keys.min

      if minimum_distance < allowed_distance
        suggestions = distances[minimum_distance].sort
        return suggestions
      else
        []
      end
    end

    # cheap deep clone
    def deep_clone(obj)
      json_decode(json_encode(obj))
    end
  end
end
