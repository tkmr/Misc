# -*- coding: utf-8 -*-
require 'anemone'
require 'pp'
require 'open-uri'
require 'pathname'
require 'cgi'

class Enemona
  OPTS = {
    :user_agent => "Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10_6_3; en-US) AppleWebKit/533.4 (KHTML, like Gecko) Chrome/5.0.375.55 Safari/533.4",
    :delay => 2,
  }

  def initialize url
    @base_url = URI.parse(url)
  end

  def next_page_is pattern, type = :text
    @next_pattern = pattern
    @next_type = type
  end

  def on_page_search xpath_or_css, &block
    @on_every_page_block = block
    @on_every_page_search = xpath_or_css
  end

  def start opts = {}
    result = []
    depth = opts[:depth]

    Anemone.crawl(@base_url, OPTS.merge(:depth_limit => depth)) do |anem|
      anem.on_every_page do |page|
        puts page.url

        page.doc.search(@on_every_page_search).each do |a|
          result << @on_every_page_block.call(page, a)
        end
      end

      anem.focus_crawl do |page|
        res = []
        page.doc.search("//a[@href]").each do |a|
          if a.send(@next_type) =~ @next_pattern
            if a.attributes['href'] =~ /^http/
              next_uri = URI.parse(a.attributes['href'])
            else
              next_uri = URI.parse(@base_url.scheme + '://' + @base_url.host + a.attributes['href'])
            end
            res << next_uri
          end
        end
        res.uniq
      end
    end

    result.select{|r| !r.nil? }
  end

  #Utilyty methods
  def download url, file_pathname
    file_pathname.open('w') do |file|
      open(url) do |page|
        file << page.read
      end
    end
  end
end




base_url = ARGV.shift
out_dir  = Pathname.new(ARGV.shift)

enem = Enemona.new base_url
enem.next_page_is(/^次の25件/)

enem.on_page_search("//a[@class='entry-link']") do |page, link|
  unless link.text =~ /続きを読む/
    begin
      body = [link.text.chomp, link.parent.parent.xpath(".//blockquote").first.text.chomp("\t").chomp("\n")].join("\n")

      open(out_dir + CGI.escape(link.attributes['href'].value), 'w') do |file|
        file << body
      end
    rescue => e
      p e
    end
  end
end

enem.start :depth => 20
