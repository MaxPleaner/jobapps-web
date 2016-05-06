require_relative 'boot'

require 'rails/all'
require 'yaml'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

class Object
  def ai(options)
    if is_a?(Hash)
      reject { |k,v| v.blank? }.reduce("") do |str, (k,v)|
        str = "<pre>" if str.blank?
        indented_v = v.to_s.split("\n").map do |line|
          "  #{line}"
        end.reject(&:blank?).join
        str += "<span class='company-attr'><small>#{k}: </small>#{indented_v}</span>"
        next str
      end + "</pre>"
    else
      super(options.merge(
        {
          indent: -2,
          :color => {
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
          }
        }
      ))
    end
  end
end

module JobappsWeb
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
  end
end
