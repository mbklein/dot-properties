require "dot_properties/version"
require 'forwardable'

class DotProperties
  extend Forwardable

  def_delegators :to_h, :each, :each_key, :each_pair, :each_value, :empty?, 
                 :fetch, :has_key?, :has_value?, :include?, :inspect, :invert,
                 :key, :key?, :keys, :length, :member?, :merge, :reject,
                 :select, :size, :value?, :values, :values_at


  # @!attribute [rw] auto_expand
  #   @return [Boolean] Whether to expand resolvable variables within values on retrieval (default: +true+)
  # @!attribute [rw] default_delimiter
  #   @return [String] The delimiter to use when adding new properties or when calling +normalize_delimiters!+ (default: '=')
  attr_accessor :auto_expand, :default_delimiter

  def initialize(lines=[])
    @content = lines.collect { |item| tokenize(item) }
    @auto_expand = true
    @default_delimiter = '='
  end

  def self.load(file)
    self.parse(File.read(file))
  end

  def self.parse(str)
    self.new(str.split(/(?<!\\)\n/))
  end

  def get(key, expand=@auto_expand)
    item = find_key(key)
    value = (item && item[:value]) || nil
    if value and expand
      value = value.gsub(/\$\{(.+?)\}/) { |v| has_key?($1) ? get($1,true) : v }
    end
    return value
  end

  def set(key, value)
    item = find_key(key)
    if item
      item[:value] = value
    else
      @content << { type: :value, key: key, delimiter: default_delimiter, value: value }
    end
    return value
  end

  def [](key)
    get(key)
  end

  def []=(key,value)
    set(key, value)
  end

  def <<(item)
    @content << tokenize(item)
  end

  def delete(key)
    value = get(key)
    @content.reject! { |item| item[:type] == :value and item[:key] == key }
    return value
  end

  def inspect
    to_h.inspect
  end

  # Strip all comments and blank lines, leaving only values
  def compact!
    @content.reject! { |item| item[:type] != :value }
  end

  # Replace all delimiters with +default_delimiter+
  def normalize_delimiters!
    @content.each { |item| item[:delimiter] = default_delimiter if item[:type] == :value }
  end

  # Strip all blank lines, leaving only comments and values
  def strip_blanks!
    @content.reject! { |item| item[:type] == :blank }
  end

  # Strip all comments, leaving only blank lines and values
  def strip_comments!
    @content.reject! { |item| item[:type] == :comment }
  end

  # The assembled .properties file as an array of lines
  def to_a
    @content.collect { |item| assemble(item) }
  end

  # All properties as a hash
  def to_h
    Hash[@content.select { |item| item[:type] == :value }.collect { |item| item.values_at(:key,:value) }]
  end
  
  # The assembled .properties file as a string
  def to_s
    to_a.join("\n")
  end

  protected
  def assemble(item)
    if item[:type] == :value
      if item[:value].nil? or item[:value].empty?
        escape(item[:key])
      else
        "#{escape(item[:key])}#{item[:delimiter]}#{encode(item[:value])}"
      end
    else
      item[:value]
    end
  end

  def tokenize(item)
    if item =~ /^\s*[#!]/
      { type: :comment, value: item }
    elsif item =~ /^\s*$/
      { type: :blank, value: item }
    else
      key, delimiter, value = item.strip.split /(\s*(?<!\\)[\s:=]\s*)/, 2
      { type: :value, key: unescape(decode(key)), delimiter: delimiter, value: unescape(decode(value.to_s.gsub(/\\\n\s*/,''))) }
    end
  end

  def find_key(key)
    @content.find { |item| item[:type] == :value and item[:key] == key }
  end

  def encode(v)
    v.gsub(/[\r\n]/) { |m| "\\u#{'%4.4X' % m.codepoints.to_a}" }.gsub(/\\/,'\\'*3)
  end

  def decode(v)
    v.gsub(/\\u([0-9A-Fa-f]{4})/) { |m| $1.hex.chr('UTF-8') }
  end

  def escape(v)
    v.gsub(/[\s:=\\]/) { |m| "\\#{m}" }
  end

  def unescape(v)
    v.gsub(/(?<!\\)\\/,'')
  end

end
