require_relative 'boot'

require 'rails/all'
require 'yaml'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

class Object
  def ai(options)
    super(options.merge(
      {:color => {
          :args       => :white,
          :array      => :white,
          :bigdecimal => :white,
          :class      => :white,
          :date       => :white,
          :falseclass => :white,
          :fixnum     => :white,
          :float      => :white,
          :hash       => :white,
          :keyword    => :white,
          :method     => :white,
          :nilclass   => :white,
          :rational   => :white,
          :string     => :white,
          :struct     => :white,
          :symbol     => :white,
          :time       => :white,
          :trueclass  => :white,
          :variable   => :white
      }}
  ))
  end
end

module JobappsWeb
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
  end
end
