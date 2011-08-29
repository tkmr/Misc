require 'rubygems'
require 'open-uri'
require 'hpricot'
require 'ruby-debug'

module Web
  class Page
    def initialize(url)
      @page = Hpricot(open(url))
    end

    def links
      @page/"a"
    end
  end
end

module Beyze
  class Teacher
    def initialize(category_names)
      @categories = {}
      category_names.each {|c| @categories[c] = Category.new(c) }
    end

    def teach(name, pages)
      pages.each do |page|
        page.links.map do |a|
          @categories[name].lern a['href']
        end
      end
    end
  end

  class Category
    def initialize(name)
      @name = name
      @score = Hash.new {|h, k| h[k] = 0 }
    end

    def lern(url_str)
      @score[url_str.to_s] += 1
    end
  end
end

gihyo = Web::Page.new('http://gihyo.jp/dev/serial/01/machine-learning/0003')
gihyo.links.



