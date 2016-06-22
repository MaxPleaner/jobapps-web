require 'active_support/all'
require 'json'
require "indeed-ruby"
require 'awesome_print'
require 'nokogiri'
require 'open-uri'
require 'open_uri_redirections'
require 'mechanize'

module FindJobListings
	Agent = Mechanize.new
	class Indeed_API
		attr_reader :client # an Indeed::Client
		def initialize
      publisher_number = ENV["INDEED_PUBLISHER_NUMBER"] || "2553479884824039"
      raise(StandardError, "INDEED_PUBLISHER_NUMBER is not set") unless publisher_number
      @client = Indeed::Client.new(publisher_number)
		end
		def jobs(options={})
			options[:search_term] && (options[:q] = options.delete(:search_term))
			useful_data(client.search(defaults.merge(options))['results'])
		end

    private
    def defaults
			{ q: 'ruby', l: 'san francisco', limit: 20, start: 0, userip: '1.2.3.4',
				useragent: 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko)' +
                   'Ubuntu Chromium/44.0.2403.89 Chrome/44.0.2403.89 Safari/537.36'
			}
		end
		def useful_data(jobs)
			jobs.map { |job| {
        jobtitle: job['jobtitle'],
        description: job['snippet'],
        company: job['company'],
        location: job['formattedLocation'],
        url: job['url']
      }}
		end

  end # end Indeed_API

	class StackOverflow_API
		attr_reader :response_xml, :base_url
		def initialize
			@base_url = "http://careers.stackoverflow.com/jobs/feed"
		end
		def jobs(options={})
			options = defaults.merge(options)
      params_string = options.map{ |k,v| k == :search_term ? "searchTerm[]="#{v}" : #{k}=#{v}" }.join("&")
			url = URI::encode( "#{base_url}?#{params_string}" )
			open(url, allow_redirections: :safe) { |results| @response_xml = results.read }
			items = Nokogiri::XML(response_xml).css("item")
			results = useful_data(items)
			limit = options[:limit]&.to_i
			offset = options[:start].to_i * limit.to_i if limit
			results[offset...(offset + limit)]
		end

    private
		def defaults
			search_term = "ruby"
			{
				location: "San Francisco",
				range: 20,
				limit: 2,
				start: 0,
#				search_term: "software&searchTerm[]=programmer&searchTerm[]=developer&searchTerm[]=ruby&searchTerm[]=javascript"
				search_term: search_term
			}
		end
		def useful_data(items)
			items.map do |item|
				{
					title: item.css("title").text,
					description: item.css("description").text,
					location: item.css("location").text.first(250),
					link: item.css("link").text,
				}
			end
		end

	end # end StackOverflow_API

end # end FindJobListings

