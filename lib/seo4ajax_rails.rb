module Rack
  class SEO4Ajax
    require 'net/http'
    require 'active_support'

    def initialize(app, options={})
      # googlebot, yahoo, and bingbot are not in this list because
      # we support _escaped_fragment_ and want to ensure people aren't
      # penalized for cloaking.
      @crawler_user_agents = [
        # 'googlebot',
        # 'yahoo',
        # 'bingbot',
        'baiduspider',
        'facebookexternalhit',
        'twitterbot',
        'rogerbot',
        'linkedinbot',
        'embedly',
        'bufferbot',
        'quora link preview',
        'showyoubot',
        'outbrain',
        'pinterest/0.',
        'developers.google.com/+/web/snippet',
        'www.google.com/webmasters/tools/richsnippets',
        'slackbot',
        'vkShare',
        'W3C_Validator',
        'redditbot',
        'Applebot',
        'WhatsApp',
        'flipboard',
        'tumblr',
        'bitlybot',
        'SkypeUriPreview',
        'nuzzel',
        'Discordbot',
        'Google Page Speed',
        'Qwantify'
      ]

      @extensions_to_ignore = [
        '.js',
        '.css',
        '.xml',
        '.less',
        '.png',
        '.jpg',
        '.jpeg',
        '.gif',
        '.pdf',
        '.doc',
        '.txt',
        '.ico',
        '.rss',
        '.zip',
        '.mp3',
        '.rar',
        '.exe',
        '.wmv',
        '.doc',
        '.avi',
        '.ppt',
        '.mpg',
        '.mpeg',
        '.tif',
        '.wav',
        '.mov',
        '.psd',
        '.ai',
        '.xls',
        '.mp4',
        '.m4a',
        '.swf',
        '.dat',
        '.dmg',
        '.iso',
        '.flv',
        '.m4v',
        '.torrent'
      ]

      @options = options
      @extensions_to_ignore = @options[:extensions_to_ignore] if @options[:extensions_to_ignore]
      @crawler_user_agents = @options[:crawler_user_agents] if @options[:crawler_user_agents]
      @app = app
    end


    def call(env)
      if should_show_snapshot(env)
        snapshot = get_snapshot_response(env)
        if snapshot
          response = build_rack_response_from_seo4ajax(snapshot)
          return response.finish
        end
      end
      @app.call(env)
    end


    def should_show_snapshot(env)
      user_agent = env['HTTP_USER_AGENT']
      is_requesting_snapshot = false
      return false if !user_agent
      return false if env['REQUEST_METHOD'] != 'GET'
      request = Rack::Request.new(env)
      is_requesting_snapshot = true if Rack::Utils.parse_query(request.query_string).has_key?('_escaped_fragment_')
      is_requesting_snapshot = true if @crawler_user_agents.any? { |crawler_user_agent| user_agent.downcase.include?(crawler_user_agent.downcase) }
      return false if @extensions_to_ignore.any? { |extension| request.fullpath.include? extension }
      return is_requesting_snapshot
    end


    def get_snapshot_response(env)
      begin
        url = URI.parse(build_api_url(env))        
        headers = {
          'User-Agent' => env['HTTP_USER_AGENT'],
          'Accept-Encoding' => 'gzip'
        }
        req = Net::HTTP::Get.new(url.request_uri, headers)
        http = Net::HTTP.new(url.host, url.port)
        http.use_ssl = true if url.scheme == 'https'
        response = http.request(req)
        if response['Content-Encoding'] == 'gzip'
          response.body = ActiveSupport::Gzip.decompress(response.body)
          response['Content-Length'] = response.body.length
          response.delete('Content-Encoding')
          response.delete('Transfer-Encoding')
        end
        response
      rescue
        nil
      end  
    end


    def build_api_url(env)
      fullpath = Rack::Request.new(env).fullpath
      seo4ajax_url = @options[:seo4ajax_service_url] || ENV['SEO4AJAX_SERVICE_URL'] || 'http://api.seo4ajax.com/'
      forward_slash = seo4ajax_url[-1, 1] == '/' ? '' : '/'
      token = ENV['SEO4AJAX_TOKEN'] if ENV['SEO4AJAX_TOKEN']
      token = @options[:seo4ajax_token] if @options[:seo4ajax_token]      
      "#{seo4ajax_url}#{forward_slash}#{token}#{fullpath}"
    end


    def build_rack_response_from_seo4ajax(snapshot)
      Rack::Response.new(snapshot.body, snapshot.code, snapshot.header)
    end
  end
end