#
# Fluentd
#
#    Licensed under the Apache License, Version 2.0 (the "License");
#    you may not use this file except in compliance with the License.
#    You may obtain a copy of the License at
#
#        http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS,
#    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#    See the License for the specific language governing permissions and
#    limitations under the License.
#

require 'time'
require 'msgpack'
require 'strptime'
require 'fluent/timezone'
require 'fluent/configurable'
require 'fluent/config/error'

module Fluent
  class EventTime
    TYPE = 0
    FORMATTER = Strftime.new('%Y-%m-%d %H:%M:%S.%N %z')

    def initialize(sec, nsec = 0)
      @sec = sec
      @nsec = nsec
    end

    def ==(other)
      if other.is_a?(Fluent::EventTime)
        @sec == other.sec
      else
        @sec == other
      end
    end

    def sec
      @sec
    end

    def nsec
      @nsec
    end

    def to_int
      @sec
    end
    alias :to_i :to_int

    def to_f
      @sec + @nsec / 1_000_000_000.0
    end

    # for Time.at
    def to_r
      Rational(@sec * 1_000_000_000 + @nsec, 1_000_000_000)
    end

    # for > and others
    def coerce(other)
      [other, @sec]
    end

    def to_s
      @sec.to_s
    end

    begin
      # ruby 2.5 or later
      Time.at(0, 0, :nanosecond)

      def to_time
        Time.at(@sec, @nsec, :nanosecond)
      end
    rescue
      def to_time
        Time.at(Rational(@sec * 1_000_000_000 + @nsec, 1_000_000_000))
      end
    end

    def to_json(*args)
      @sec.to_s
    end

    def to_msgpack(io = nil)
      @sec.to_msgpack(io)
    end

    def to_msgpack_ext
      [@sec, @nsec].pack('NN')
    end

    def self.from_msgpack_ext(data)
      new(*data.unpack('NN'))
    end

    def self.from_time(time)
      Fluent::EventTime.new(time.to_i, time.nsec)
    end

    def self.eq?(a, b)
      if a.is_a?(Fluent::EventTime) && b.is_a?(Fluent::EventTime)
        a.sec == b.sec && a.nsec == b.nsec
      else
        a == b
      end
    end

    def self.now
      # This method is called many time. so call Process.clock_gettime directly instead of Fluent::Clock.real_now
      now = Process.clock_gettime(Process::CLOCK_REALTIME, :nanosecond)
      Fluent::EventTime.new(now / 1_000_000_000, now % 1_000_000_000)
    end

    def self.parse(*args)
      from_time(Time.parse(*args))
    end

    ## TODO: For performance, implement +, -, and so on
    def method_missing(name, *args, &block)
      @sec.send(name, *args, &block)
    end

    def inspect
      FORMATTER.exec(Time.at(self))
    end
  end

  module TimeMixin
    TIME_TYPES = ['string', 'unixtime', 'float', 'mixed']

    TIME_PARAMETERS = [
      [:time_format, :string, {default: nil}],
      [:localtime, :bool, {default: true}],  # UTC if :localtime is false and :timezone is nil
      [:utc,       :bool, {default: false}], # to turn :localtime false
      [:timezone, :string, {default: nil}],
      [:time_format_fallbacks, :array, {default: []}], # try time_format, then try fallbacks
    ]
    TIME_FULL_PARAMETERS = [
      # To avoid to define :time_type twice (in plugin_helper/inject)
      [:time_type, :enum, {default: :string, list: TIME_TYPES.map(&:to_sym)}],
    ] + TIME_PARAMETERS

    module TimeParameters
      include Fluent::Configurable
      TIME_FULL_PARAMETERS.each do |name, type, opts|
        config_param(name, type, **opts)
      end

      def configure(conf)
        if conf.has_key?('localtime') || conf.has_key?('utc')
          if conf.has_key?('localtime')
            conf['localtime'] = Fluent::Config.bool_value(conf['localtime'])
          elsif conf.has_key?('utc')
            conf['localtime'] = !(Fluent::Config.bool_value(conf['utc']))
            # Specifying "localtime false" means using UTC in TimeFormatter
            # And specifying "utc" is different from specifying "timezone +0000"(it's not always UTC).
            # There are difference between "Z" and "+0000" in timezone formatting.
            # TODO: add kwargs to TimeFormatter to specify "using localtime", "using UTC" or "using specified timezone" in more explicit way
          end
        end

        super

        if conf.has_key?('localtime') && conf.has_key?('utc') && !(@localtime ^ @utc)
          raise Fluent::ConfigError, "both of utc and localtime are specified, use only one of them"
        end

        if conf.has_key?('time_type') and @time_type == :mixed
          if @time_format.nil? and @time_format_fallbacks.empty?
            raise Fluent::ConfigError, "time_type is :mixed but time_format and time_format_fallbacks is empty."
          end
        end

        Fluent::Timezone.validate!(@timezone) if @timezone
      end
    end

    module Parser
      def self.included(mod)
        mod.include TimeParameters
      end

      def time_parser_create(type: @time_type, format: @time_format, timezone: @timezone, force_localtime: false)
        return MixedTimeParser.new(type, format, @localtime, timezone, @utc, force_localtime, @time_format_fallbacks) if type == :mixed
        return NumericTimeParser.new(type) if type != :string
        return TimeParser.new(format, true, nil) if force_localtime

        localtime = @localtime && (timezone.nil? && !@utc)
        TimeParser.new(format, localtime, timezone)
      end
    end

    module Formatter
      def self.included(mod)
        mod.include TimeParameters
      end

      def time_formatter_create(type: @time_type, format: @time_format, timezone: @timezone, force_localtime: false)
        return NumericTimeFormatter.new(type) if type != :string
        return TimeFormatter.new(format, true, nil) if force_localtime

        localtime = @localtime && (timezone.nil? && !@utc)
        TimeFormatter.new(format, localtime, timezone)
      end
    end
  end

  class TimeParser
    class TimeParseError < StandardError; end

    def initialize(format = nil, localtime = true, timezone = nil)
      if format.nil? && (timezone || !localtime)
        raise Fluent::ConfigError, "specifying timezone requires time format"
      end

      @cache1_key = nil
      @cache1_time = nil
      @cache2_key = nil
      @cache2_time = nil

      format_with_timezone = format && (format.include?("%z") || format.include?("%Z"))

      utc_offset = case
                   when format_with_timezone then
                     nil
                   when timezone then
                     Fluent::Timezone.utc_offset(timezone)
                   when localtime then
                     nil
                   else
                     0 # utc
                   end

      strptime = format && (Strptime.new(format) rescue nil)

      @parse = case
               when format_with_timezone && strptime then ->(v){ Fluent::EventTime.from_time(strptime.exec(v)) }
               when format_with_timezone             then ->(v){ Fluent::EventTime.from_time(Time.strptime(v, format)) }
               when format == '%iso8601'             then ->(v){ Fluent::EventTime.from_time(Time.iso8601(v)) }
               when strptime then
                 if utc_offset.nil?
                   ->(v){ t = strptime.exec(v); Fluent::EventTime.new(t.to_i, t.nsec) }
                 elsif utc_offset.respond_to?(:call)
                   ->(v) { t = strptime.exec(v); Fluent::EventTime.new(t.to_i + t.utc_offset - utc_offset.call(t), t.nsec) }
                 else
                   ->(v) { t = strptime.exec(v); Fluent::EventTime.new(t.to_i + t.utc_offset - utc_offset, t.nsec) }
                 end
               when format then
                 if utc_offset.nil?
                   ->(v){ t = Time.strptime(v, format); Fluent::EventTime.new(t.to_i, t.nsec) }
                 elsif utc_offset.respond_to?(:call)
                   ->(v){ t = Time.strptime(v, format); Fluent::EventTime.new(t.to_i + t.utc_offset - utc_offset.call(t), t.nsec) }
                 else
                   ->(v){ t = Time.strptime(v, format); Fluent::EventTime.new(t.to_i + t.utc_offset - utc_offset, t.nsec) }
                 end
               else ->(v){ Fluent::EventTime.parse(v) }
               end
    end

    # TODO: new cache mechanism using format string
    def parse(value)
      unless value.is_a?(String)
        raise TimeParseError, "value must be string: #{value}"
      end

      if @cache1_key == value
        return @cache1_time
      elsif @cache2_key == value
        return @cache2_time
      else
        begin
          time = @parse.call(value)
        rescue => e
          raise TimeParseError, "invalid time format: value = #{value}, error_class = #{e.class.name}, error = #{e.message}"
        end
        @cache1_key = @cache2_key
        @cache1_time = @cache2_time
        @cache2_key = value
        @cache2_time = time
        return time
      end
    end
    alias :call :parse
  end

  class NumericTimeParser < TimeParser # to include TimeParseError
    def initialize(type, localtime = nil, timezone = nil)
      @cache1_key = @cache1_time = @cache2_key = @cache2_time = nil

      if type == :unixtime
        define_singleton_method(:parse, method(:parse_unixtime))
        define_singleton_method(:call, method(:parse_unixtime))
      else # :float
        define_singleton_method(:parse, method(:parse_float))
        define_singleton_method(:call, method(:parse_float))
      end
    end

    def parse_unixtime(value)
      unless value.is_a?(String) || value.is_a?(Numeric)
        raise TimeParseError, "value must be a string or a number: #{value}(#{value.class})"
      end

      if @cache1_key == value
        return @cache1_time
      elsif @cache2_key == value
        return @cache2_time
      end

      begin
        time = Fluent::EventTime.new(value.to_i)
      rescue => e
        raise TimeParseError, "invalid time format: value = #{value}, error_class = #{e.class.name}, error = #{e.message}"
      end
      @cache1_key = @cache2_key
      @cache1_time = @cache2_time
      @cache2_key = value
      @cache2_time = time
      time
    end

    # rough benchmark result to compare handmade parser vs Fluent::EventTime.from_time(Time.at(value.to_r))
    # full: with 9-digits of nsec after dot
    # msec: with 3-digits of msec after dot
    # 10_000_000 times loop on MacBookAir
    ## parse_by_myself(full): 12.162475 sec
    ## parse_by_myself(msec): 15.050435 sec
    ## parse_by_to_r  (full): 28.722362 sec
    ## parse_by_to_r  (msec): 28.232856 sec
    def parse_float(value)
      unless value.is_a?(String) || value.is_a?(Numeric)
        raise TimeParseError, "value must be a string or a number: #{value}(#{value.class})"
      end

      if @cache1_key == value
        return @cache1_time
      elsif @cache2_key == value
        return @cache2_time
      end

      begin
        sec_s, nsec_s, _ = value.to_s.split('.', 3) # throw away second-dot and later
        nsec_s = nsec_s && nsec_s[0..9] || '0'
        nsec_s += '0' * (9 - nsec_s.size) if nsec_s.size < 9
        time = Fluent::EventTime.new(sec_s.to_i, nsec_s.to_i)
      rescue => e
        raise TimeParseError, "invalid time format: value = #{value}, error_class = #{e.class.name}, error = #{e.message}"
      end
      @cache1_key = @cache2_key
      @cache1_time = @cache2_time
      @cache2_key = value
      @cache2_time = time
      time
    end
  end

  class TimeFormatter
    def initialize(format = nil, localtime = true, timezone = nil)
      @tc1 = 0
      @tc1_str = nil
      @tc2 = 0
      @tc2_str = nil

      strftime = format && (Strftime.new(format) rescue nil)
      if format && format =~ /(^|[^%])(%%)*%L|(^|[^%])(%%)*%\d*N/
        define_singleton_method(:format, method(:format_with_subsec))
        define_singleton_method(:call, method(:format_with_subsec))
      else
        define_singleton_method(:format, method(:format_without_subsec))
        define_singleton_method(:call, method(:format_without_subsec))
      end

      formatter = Fluent::Timezone.formatter(timezone, strftime ? strftime : format)
      @format_nocache = case
                        when formatter             then formatter
                        when strftime && localtime then ->(time){ strftime.exec(Time.at(time)) }
                        when format && localtime   then ->(time){ Time.at(time).strftime(format) }
                        when strftime              then ->(time){ strftime.exec(Time.at(time).utc) }
                        when format                then ->(time){ Time.at(time).utc.strftime(format) }
                        when localtime             then ->(time){ Time.at(time).iso8601 }
                        else                            ->(time){ Time.at(time).utc.iso8601 }
                        end
    end

    def format_without_subsec(time)
      if @tc1 == time
        return @tc1_str
      elsif @tc2 == time
        return @tc2_str
      else
        str = format_nocache(time)
        if @tc1 < @tc2
          @tc1 = time
          @tc1_str = str
        else
          @tc2 = time
          @tc2_str = str
        end
        return str
      end
    end

    def format_with_subsec(time)
      if Fluent::EventTime.eq?(@tc1, time)
        return @tc1_str
      elsif Fluent::EventTime.eq?(@tc2, time)
        return @tc2_str
      else
        str = format_nocache(time)
        if @tc1 < @tc2
          @tc1 = time
          @tc1_str = str
        else
          @tc2 = time
          @tc2_str = str
        end
        return str
      end
    end

    ## Dynamically defined in #initialize
    # def format(time)
    # end

    def format_nocache(time)
      @format_nocache.call(time)
    end
  end

  class NumericTimeFormatter < TimeFormatter
    def initialize(type, localtime = nil, timezone = nil)
      @cache1_key = @cache1_time = @cache2_key = @cache2_time = nil

      if type == :unixtime
        define_singleton_method(:format, method(:format_unixtime))
        define_singleton_method(:call, method(:format_unixtime))
      else # :float
        define_singleton_method(:format, method(:format_float))
        define_singleton_method(:call, method(:format_float))
      end
    end

    def format_unixtime(time)
      time.to_i.to_s
    end

    def format_float(time)
      if time.is_a?(Fluent::EventTime) || time.is_a?(Time)
        # 10.015 secs for 10_000_000 times call on MacBookAir
        nsec_s = time.nsec.to_s
        nsec_s = '0' * (9 - nsec_s.size) if nsec_s.size < 9
        "#{time.sec}.#{nsec_s}"
      else # integer (or float?)
        time.to_f.to_s
      end
    end
  end

  # MixedTimeParser is available when time_type is set to :mixed
  #
  # Use Case 1: primary format is specified explicitly in time_format
  #  time_type mixed
  #  time_format %iso8601
  #  time_format_fallbacks unixtime
  # Use Case 2: time_format is omitted
  #  time_type mixed
  #  time_format_fallbacks %iso8601, unixtime
  #
  class MixedTimeParser < TimeParser # to include TimeParseError
    def initialize(type, format = nil, localtime = nil, timezone = nil, utc = nil, force_localtime = nil, fallbacks = [])
      @parsers = []
      fallbacks.unshift(format).each do |fallback|
        next unless fallback
        case fallback
        when 'unixtime', 'float'
          @parsers << NumericTimeParser.new(fallback, localtime, timezone)
        else
          if force_localtime
            @parsers << TimeParser.new(fallback, true, nil)
          else
            localtime = localtime && (timezone.nil? && !utc)
            @parsers << TimeParser.new(fallback, localtime, timezone)
          end
        end
      end
    end

    def parse(value)
      @parsers.each do |parser|
        begin
          Float(value) if parser.class == Fluent::NumericTimeParser
        rescue
          next
        end
        begin
          return parser.parse(value)
        rescue
          # skip TimeParseError
        end
      end
      fallback_class = @parsers.collect do |parser| parser.class end.join(",")
      raise TimeParseError, "invalid time format: value = #{value}, even though fallbacks: #{fallback_class}"
    end
  end

end
