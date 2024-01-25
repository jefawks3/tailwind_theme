# TailwindTheme

Tailwind Theme makes it easy to DRY up your Tailwind CSS components by storing the css classnames in a single YAML file.

Tailwind Theme uses [`tailwind_merge`](https://github.com/gjtorikian/tailwind_merge) to merge the resulting
Tailwind CSS classes.

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add tailwind_theme

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install tailwind_theme

```ruby
require "tailwind_theme"

theme = TailwindTheme.load_file("theme.yml")
theme.css("button", object: button)

```

Add your theme file location to your `tailwind.config.js` file.

```javascript
/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
      // Rest of content configuration
      'path/to/theme/files/**/*.yml'
  ],
  // Rest of tailwind configuration
}
```

## What is it for?

If you use Tailwind with your Rails application, you know Tailwind cannot process runtime configurations like 
`"bg-#{color}"`, making it difficult to have dynamic yet predefined components. 

So you are left with two options:

1. CSS Abstraction for components, like Buttons, Alerts, etc., which Tailwind **does not** recommend doing too early.
   (See https://tailwindcss.com/docs/reusing-styles#compared-to-css-abstractions)
2. Or, create a partial for each Button variation (that is just a mess).

This is where `tailwind-theme` comes in by keeping your component themes consistent, dynamic, and in one place.

Rending a button dynamically is as simple as:

```ruby
@theme = TailwindTheme.load_file("theme.yml")
classnames = @theme.css("button", attributes: { variant: :outline, color: :blue, size: :base })

content_tag :button, content, class: classnames 
```

Or if you have a button object or using View Components, you can do:

```ruby
class ButtonComponent < ViewComponent::Base
  def initialize(theme:, size: :base, color: :blue, variant: :solid)
    @theme = theme
    @size = size
    @color = color
    @variant = variant
  end
  
  def call
    content_tag :button, content, class: @theme.css("button", object: self)
  end
end

```

```erb
<%= render(ButtonComponent.new(variant: :outline, color: :blue)) %>
```

## Example Theme File 

```yaml
text:
  truncated: truncate whitespace-nowrap
button:
  base: >-
    text-center font-medium rounded-lg 
    focus:ring-4 focus:outline-none
  pill: rounded-full
  size:
    xs: px-3 py-2 text-xs
    sm: px-3 py-2 text-sm
    base: px-5 py-2.5 text-sm
    lg: px-5 py-3 text-base
    xl: px-6 py-3.5 text-base
  variant:
    solid:
      color:
        blue: >-
          text-white bg-blue-700 dark:bg-blue-600
          hover:bg-blue-800 dark:hover:bg-blue-700
          focus:ring-blue-300 dark:focus:ring-blue-800
        red: >-
          text-white bg-red-700 dark:bg-red-600
          hover:bg-red-800 dark:hover:bg-red-700
          focus:ring-red-300 dark:focus:ring-red-800
        green: >-
          text-white bg-green-700 dark:bg-green-600
          hover:bg-green-800 dark:hover:bg-green-700
          focus:ring-green-300 dark:focus:ring-green-800
        yellow: >- 
          text-white bg-yellow-400 hover:bg-yellow-500
          focus:ring-yellow-300 dark:focus:ring-yellow-900
        indigo: >-
          text-white bg-indigo-700 dark:bg-indigo-600
          hover:bg-indigo-800 dark:hover:bg-indigo-700
          focus:ring-indigo-300 dark:focus:ring-indigo-800
        purple: >-
          text-white bg-purple-700 dark:bg-purple-600
          hover:bg-purple-800 dark:hover:bg-purple-700
          focus:ring-purple-300 dark:focus:ring-purple-800
        pink: >-
          text-white bg-pink-700 dark:bg-pink-600
          hover:bg-pink-800 dark:hover:bg-pink-700
          focus:ring-pink-300 dark:focus:ring-pink-800
    outline:
      base: border
      color:
        blue: >-
          text-blue-700 border-blue-700 dark:text-blue-500 dark:border-blue-500
          hover:text-white hover:bg-blue-800 dark:hover:text-white dark:hover:bg-blue-500 
          focus:ring-blue-300 dark:focus:ring-blue-800
        red: >-
          text-red-700 border-red-700 dark:text-red-500 dark:border-red-500
          hover:text-white hover:bg-red-800 dark:hover:text-white dark:hover:bg-red-500 
          focus:ring-red-300 dark:focus:ring-red-800
        green: >-
          text-green-700 border-green-700 dark:text-green-500 dark:border-green-500
          hover:text-white hover:bg-green-800 dark:hover:text-white dark:hover:bg-green-500 
          focus:ring-green-300 dark:focus:ring-green-800
        yellow: >-
          text-yellow-700 border-yellow-700 dark:text-yellow-500 dark:border-yellow-500
          hover:text-white hover:bg-yellow-800 dark:hover:text-white dark:hover:bg-yellow-500 
          focus:ring-yellow-300 dark:focus:ring-yellow-800
        indigo: >-
          text-indigo-700 border-indigo-700 dark:text-indigo-500 dark:border-indigo-500
          hover:text-white hover:bg-indigo-800 dark:hover:text-white dark:hover:bg-indigo-500 
          focus:ring-indigo-300 dark:focus:ring-indigo-800
        purple: >-
          text-purple-700 border-purple-700 dark:text-purple-500 dark:border-purple-500
          hover:text-white hover:bg-purple-800 dark:hover:text-white dark:hover:bg-purple-500 
          focus:ring-purple-300 dark:focus:ring-purple-800
        pink: >-
          text-pink-700 border-pink-700 dark:text-pink-500 dark:border-pink-500
          hover:text-white hover:bg-pink-800 dark:hover:text-white dark:hover:bg-pink-500 
          focus:ring-pink-300 dark:focus:ring-pink-800
```

## Loading a Tailwind CSS theme

From a YAML file:

```ruby
@theme = TailwindTheme.load_file("path/to/theme.yaml")
```

From a hash object (string keys):

```ruby
@theme = TailwindTheme::Theme.new({
  "button" => {
    # Button Component 
  },
  "alert" => {
    # Alert Component
  }
})
```

## Basic Usage

Retrieving a CSS class:

```ruby
@theme.css("text.truncated")
```

Applying a theme to an object:

```ruby
@theme.css(:button, object: button)
```

Applying a theme based on some attributes:

```ruby
@theme.css(:button, attributes: { color: :blue })
```

Combining multiple themes from different paths:

```ruby
@theme.merge_css([:modal, :dialog], attributes: modal_attributes)
```

## Methods

### `css(path, options=)`

Resolves the `path` and merges the Tailwind CSS classnames using `tailwind_merge`.
If `path` resolves to a [Hash], the methods and attributes from `options[:object]` and/or `options[:attributes]` will
be used to generate the classnames.

Arguments:
- **`path`** *[String, Symbol, Array<String, Symbol>]* - the path to use to extract the Tailwind CSS classnames.
- **`options[:raise]**` [Boolean] - raise a `IndexError` exception when the path is not defined in the theme.
- **`options[:object]** [Object] - the object to apply the theme to based on the object's methods.
- **`options[:attributes]**` [Hash<String, Symbol>] - the attribute hash to apply the theme to; `options[:attributes]`
 overrides `options[:object]` method values if both are defined.

Raises:
- `IndexError` if `options[:raise]` is `true` and the `path` cannot be found.
- `ArgumentError` if `path` resolves to a [Hash] and `options[:object]` or `options[:attributes]` is not defined.

Returns:
- The theme classnames if `path` exists.
- `"missing-[path seperated by '-']` if `path` does not exist. 

### `css!(path, options = {})`

The same as [`css`](#csspath-options), except raise an `IndexError` if the `path` cannot be found.

### `merge_css(paths, options = {})`

Resolves multiple paths and merges them together.

Arguments:
- **`paths`** [Array<String, Symbol, Array<String, Symbol>>] - the paths to use to extract the Tailwind CSS classnames.
- **`options[:raise]**` [Boolean] - raise a `IndexError` exception when the path is not defined in the theme.
- **`options[:object]** [Object] - the object to apply the theme to based on the object's methods.
- **`options[:attributes]**` [Hash<String, Symbol>] - the attribute hash to apply the theme to; `options[:attributes]`
  overrides `options[:object]` method values if both are defined.

Raises:
- `IndexError` if `options[:raise]` is `true` and the `path` cannot be found.
- `ArgumentError` if `path` resolves to a [Hash] and `options[:object]` or `options[:attributes]` is not defined.

Returns a string of all the classnames that resolved to the paths given.

### `merge_css!(paths, options = {})`

The same as [`merge_css`](#merge_csspaths-options--), except raise an `IndexError` if a path cannot be found.

### `key?(path)`

Get if a `path` exists.

Arguments:
- **`path`** [String, Symbol, Array<String, Symbol] - the path defined in the theme.

Returns `true` if the `path` exists.

### `[](path)`

Return the value at the path without processing or merging the classnames.

Arguments:
- **`path`** [String, Symbol, Array<String, Symbol] - the path defined in the theme.

Returns:
- [String, Hash] if the `path` can be found.
- [NilClass] if the `path` cannot be found.

## Configuration

### Override the missing classname if a path cannot be found

Using a string:

```ruby
TailwindTheme.missing_classname = "missing"
```

Using a Proc:

```ruby
TailwindTheme.missing_classname = ->(paths) { "oops-#{paths.join("-")}-missing" }
```

Disabling:

```ruby
TailwindTheme.missing_classname = false
```

### Using a custom `tailwind_merge` instance

```ruby
@merger = TailwindMerge::Merger.new
TailwindTheme.merger = @merger
```

### Using a custom `tailwind_merge` configuration

```ruby
TailwindTheme.merger_config = {
  # Configuration
}

```

See https://github.com/gjtorikian/tailwind_merge?tab=readme-ov-file#configuration for more details.

## Development

After checking out the repo, run `bin/setup` to install dependencies.
Then, run `rake spec` to run the tests. You can also run `bin/console`
for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.
To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, 
which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file
to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/jefawks3/tailwind_theme.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
