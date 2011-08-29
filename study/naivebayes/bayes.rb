# -*- coding: utf-8 -*-
require 'rubygems'
require 'rinruby'
require 'pp'
require 'pathname'
require 'MeCab'
require 'stringio'

class Array
  def sum
    res = 0
    self.each {|i| res += i }
    res
  end
end

class Parser
  Tagger = MeCab::Tagger.new

  def self.parse_text text
    self.parse StringIO.new(text, 'r')
  end

  def self.parse file
    [].tap do |result|
      node = Tagger.parseToNode file.read
      while node
        word    = node.surface.force_encoding("UTF-8")
        feature = node.feature.split(',').first.force_encoding("UTF-8")

        if feature =~ /^名詞$/  and  word.size >= 2   and  !(word =~ /^([0-9a-zA-Z\.>]+|続き)$/)
          result << word
        end

        node = node.next
      end
    end
  end
end

class Bayes
  MinValue = Float::MIN
  attr_reader :docs, :words

  def initialize
    @docs  = Hash.new(0)
    @words = {}
  end

  def train category = :default, words = []
    @docs[category] += 1

    @words[category] ||= Hash.new(0)
    words.each {|w| @words[category][w] += 1 }
  end

  def predict words = []
    res = {}
    categories.each do |cat|
      res[cat] = posterior_probability(cat, words)
    end
    res
  end

  def categories
    @docs.keys
  end

  private
  def posterior_probability category, words
    words.map{|w| Math::log(likelihood(w, category)) }.sum + Math::log(prior_probability(category))
  end

  def prior_probability category
    @docs[category].to_f / @docs.map{|k,v| v }.sum
  end

  def likelihood word, category
    return MinValue if @words[category][word] == 0

    @words[category][word].to_f / total_word_num(category)
  end

  def total_word_num category
    @total_word_num_cache ||= {}
    @total_word_num_cache[category] ||= @words[category].map{|k,v| v }.sum
  end

  def spy obj
    p obj
    obj
  end
end


def dump obj, file_path
  open(file_path, 'wb') do |file|
    Marshal.dump obj, file
  end
end

def load file_path
  open(file_path, 'rb') do |file|
    Marshal.load file
  end
end


path = ARGV.shift
good_docs_dir = Pathname.new(path)

path = ARGV.shift
bad_docs_dir  = Pathname.new(path)

#mode is 'train' or 'predict'
mode = ARGV.shift || 'train'

@bayes = Bayes.new

case mode
when 'train'
  puts "Start! train mode."

  good_docs_dir.children.each_with_index do |file, i|
    @bayes.train :good, Parser.parse(file)
  end

  bad_docs_dir.children.each_with_index do |file, i|
    @bayes.train :bad, Parser.parse(file)
  end

  dump @bayes, './nbayes.data'
  puts "Success save train data. #{@bayes.docs}"

when 'predict'
  puts "Start! predict mode."
  @bayes = load './nbayes.data'

  if target_file = ARGV.shift
    words = Parser.parse Pathname.new(target_file)
  else
    words = Parser.parse_text(gets)
  end

  result = @bayes.predict(words)
  p (result[:good] > result[:bad] ? "Good" : "Bad")
  p result
end
