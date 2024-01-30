# frozen_string_literal: true

require "yaml"
require "erb"
require "tailwind_merge"

require_relative "tailwind_theme/version"

# Namespace for the tailwind_theme code
module TailwindTheme
  class << self
    # Writers for shared global objects
    attr_writer :merger, :merger_config, :missing_classname
  end

  def self.merger_config
    @merger_config ||= {}
  end

  # Returns the global [TailwindMerge::Merge](https://github.com/gjtorikian/tailwind_merge) merge object
  # using the global `merge_config` object.
  def self.merger
    @merger ||= TailwindMerge::Merger.new(config: merger_config)
  end

  # Loads the YAML theme file.
  #
  # @example
  #     TailwindTheme.load_file("path/to/theme.yml")
  #
  # @example
  #     TailwindTheme.load_file("path/to/theme.yml.erb")
  #
  # @return [TailwindTheme::Theme]
  def self.load_file(path)
    contents = File.read path
    contents = ERB.new(contents).result if path.end_with?(".erb")
    Theme.new YAML.safe_load(contents, aliases: true, filename: path)
  end

  # Generate the missing CSS class name from the path
  # @param [Array<String>] path the missing CSS path
  # @return [Nil, String] returns a nil if the global missing_classname is false, otherwise returns a string
  def self.missing_classname(path)
    if @missing_classname.nil? || @missing_classname == true
      "missing-#{path.join "-"}"
    elsif @missing_classname.is_a? Proc
      @missing_classname.call path
    elsif !!@missing_classname
      @missing_classname.to_s
    end
  end

  # The Tailwind CSS Theme object
  #
  # @example
  #     TailwindTheme::Theme.new({ button: "rounded p-8 bg-blue-600 text-white hover:bg-blue-500" })
  #
  class Theme
    # The base key name for the sub theme
    BASE_KEY = "base"
    # The key to use for a nil value
    NIL_KEY = "nil"

    def initialize(theme_hash = {})
      @theme = theme_hash
    end

    # Get the merged Tailwind CSS classes
    #
    # @param [String, Symbol, Array<String, Symbol>] path the path to the css classes or sub theme
    # @param [Hash<Symbol, Object>] options the options to use when parsing the css theme
    # @option options [Boolean] raise raise an `IndexError` if the `path` does not exist
    # @option options [Object] object the object to apply the sub theme
    # @option options [Hash<String, Object>] attributes the attributes to apply the sub theme. Overrides
    #   the attributes defined in `options[:object]`.
    #
    # Default options are:
    #   :raise => false
    #
    # @return [String] the merged Tailwind CSS classes
    #
    # @raise [IndexError] if the :raise options is true and the path cannot be found
    # @raise [ArgumentError] if processing an object theme and the object or attributes option is not defined
    def css(path, options = {})
      classnames = build path, options
      merge classnames
    end

    # Get the merged Tailwind CSS classes. Raises an IndexError if the path cannot be found.
    #
    # @param [String, Symbol, Array<String, Symbol>] path the path to the css classes or sub theme
    # @param [Hash<Symbol, Object>] options the options to use when parsing the css theme
    # @option options [Object] object the object to apply the sub theme
    # @option options [Hash<String, Object>] attributes the attributes to apply the sub theme. Overrides
    #   the attributes defined in `options[:object]`.
    #
    # @return [String] the merged Tailwind CSS classes
    #
    # @raise [IndexError] if the :raise options is true and the path cannot be found
    # @raise [ArgumentError] if processing an object theme and the object or attributes option is not defined
    def css!(path, options = {})
      css path, options.merge(raise: true)
    end

    # Combine multiple paths and merging the combined Tailwind CSS classes.
    #
    # @param [Array<String, Symbol, Array<String, Symbol>>] paths the array of paths to combine
    # @param [Hash<Symbol, Object>] options the options to use when parsing the css theme
    # @option options [Boolean] raise raise an `IndexError` if the a path does not exist
    # @option options [Object] object the object to apply the sub theme
    # @option options [Hash<String, Object>] attributes the attributes to apply the sub theme. Overrides
    #   the attributes defined in `options[:object]`.
    #
    # Default options are:
    #   :raise => false
    #
    # @return [String] the merged Tailwind CSS classes
    #
    # @raise [IndexError] if the :raise options is true and a path cannot be found
    # @raise [ArgumentError] if processing an object theme and the object or attributes option is not defined
    def merge_css(paths, options = {})
      classnames = paths.map { |path| build path, options }.compact.join(" ")
      merge classnames
    end

    # Combine multiple paths and merging the combined Tailwind CSS classes. Raises an IndexError if a path
    #   cannot be found.
    #
    # @param [Array<String, Symbol, Array<String, Symbol>>] paths the array of paths to combine
    # @param [Hash<Symbol, Object>] options the options to use when parsing the css theme
    # @option options [Object] object the object to apply the sub theme
    # @option options [Hash<String, Object>] attributes the attributes to apply the sub theme. Overrides
    #   the attributes defined in `options[:object]`.
    #
    # @return [String] the merged Tailwind CSS classes
    #
    # @raise [IndexError] if the :raise options is true and a path cannot be found
    # @raise [ArgumentError] if processing an object theme and the object or attributes option is not defined
    def merge_css!(paths, options = {})
      merge_css paths, options.merge(raise: true)
    end

    # Returns if the path exists
    # @return [Boolean] returns true if the path exists
    def key?(path)
      path = normalize_path path
      !!lookup_path(path, raise: false)
    end

    # Lookup the raw value of the path
    # @param [String, Symbol, Array[String, Symbol]] path the path to the css classes
    # @return [String, Hash, NilClass]
    def [](path)
      path = normalize_path path
      lookup_path path, raise: false
    end

    private

    def normalize_path(path)
      Array(path).map { |k| k.to_s.split "." }.flatten.map(&:to_s)
    end

    def normalize_options(options)
      options.transform_keys!(&:to_sym)
      options[:attributes]&.transform_keys!(&:to_s)
      options
    end

    def lookup_path(path, options)
      theme = path.empty? ? @theme : @theme.dig(*path)
      raise IndexError, "theme key missing: \"#{path.join "."}\"" if options[:raise] && theme.nil?

      theme
    end

    def build(path, options)
      path = normalize_path path
      options = normalize_options options
      value = lookup_path path, options
      return TailwindTheme.missing_classname(path) unless value

      process value, options
    end

    def process(value, options)
      case value
      when Array
        process_array value, options
      when Hash
        process_object_theme value, options
      else
        value
      end
    end

    def process_array(themes, options)
      themes.map { |theme| process theme, options }
    end

    def process_object_theme(object_theme, options)
      unless options[:object] || options[:attributes]
        raise ArgumentError, "Must pass the 'object' or 'attributes' option when applying an object theme."
      end

      object_theme.each_with_object([object_theme[BASE_KEY]]) do |(key, value), classname_list|
        if (classnames = process_object_theme_attr(key, value, options))
          classname_list << classnames
        end
      end
    end

    def process_object_theme_attr(attribute, object_theme, options)
      case object_theme
      when Array
        process_object_theme_array_attr(attribute, object_theme, options)
      when Hash
        process_object_theme_hash_attr(attribute, object_theme, options)
      else
        process_object_theme_string_attr(attribute, object_theme, options)
      end
    end

    def process_object_theme_array_attr(attribute, object_theme, options)
      object_theme.map { |item| process_object_theme_attr attribute, item, options }
    end

    def process_object_theme_hash_attr(attribute, object_theme, options)
      if process_from_attributes?(attribute, options)
        process_attr_value(object_theme, attributes_value(attribute, options), options)
      elsif process_from_object?(attribute, options)
        process_attr_value(object_theme, object_value(attribute, options), options)
      end
    end

    def process_object_theme_string_attr(attribute, object_theme, options)
      if process_from_attributes?(attribute, options)
        object_theme if attributes_value(attribute, options)
      elsif process_from_object?(attribute, options)
        object_theme if object_value(attribute, options)
      end
    end

    def process_from_attributes?(attribute, options)
      options[:attributes]&.key?(attribute)
    end

    def process_from_object?(attribute, options)
      options[:object].respond_to?(attribute, true)
    end

    def attributes_value(attribute, options)
      options.dig :attributes, attribute
    end

    def object_value(attribute, options)
      options[:object].send attribute
    end

    def process_attr_value(object_theme, value, options)
      key = value_to_key value
      [object_theme[BASE_KEY], process(object_theme[key], options)]
    end

    def value_to_key(value)
      if value.nil?
        NIL_KEY
      elsif value.is_a?(TrueClass) || value.is_a?(FalseClass)
        value
      else
        value.to_s
      end
    end

    def merge(classnames)
      classnames = Array(classnames).flatten.compact.join(" ")
      TailwindTheme.merger.merge classnames
    end
  end
end
