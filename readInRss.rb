# -*- coding: utf-8 -*-
require 'rss/2.0'
require 'open-uri'
require 'fileutils'

# ref: http://rubyrss.com/

#FileUtils.mkdir "_posts"

open('http://0.0.0.0/fayu.xml') do |http|
  response = http.read
  result = RSS::Parser.parse(response, false)
#  puts "Channel: " + result.channel.title
  result.items.each_with_index do |item, i|
    id = i-603
    title =  item.title.to_s.chomp
    # some item are blank titles
    # we cant allow this, otherwise the following gsub exits if working on a blank string, aka Nil
    # so, fill in some gibberish
    if title == nil
      title = "no title"
    end
    # following characters might be illegal in YMAL
    #     " : [ ] { } |
    # 参考：http://zh.wikipedia.org/zh/YAML
    # " 是因为我的程序后面会统一添加"value", : 是因为它是键值分割符号
    # [] {} 是因为它们也可以有特殊含义 [milk, pumpkin pie, eggs, juice]
    # {name: John Smith, age: 33}
    # | 是因为它作为 保存新行(Newlines preserved)
    # which results yaml parse error and site won't generate
    # so lets subsitute those " here

    mytitle=title.gsub('http://', '') # first one is mytitle=title.

    mytitle=mytitle.gsub(/[*\[\]{}:"()'#：；！？（）=，,?! 《》|]/, ' ') # works

    mytitle=mytitle.gsub(/^ +/, '')
    mytitle=mytitle.gsub(/ +/, ' ')
    mytitle=mytitle.gsub(/^$/, 'no title')




    # pubdae: 2012-02-16T14:36:54+08:00-id
    pubdate = item.date.xmlschema
    # date: 2012-02-16
    date = pubdate.slice(0,10)

    content = item.description.to_s

   File.open("#{date}#{id}.markdown", "w:utf-8") do |file|
      file.puts "---"
      file.puts "title: #{mytitle} "
      file.puts "layout: post"
      file.puts "author: lm"
      file.puts "---"
      file.puts content
    end
  end      # end each_with_index

end # end open('http://0.0.0.0/rss.xml') do |http|


