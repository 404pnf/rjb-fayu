# -*- coding: utf-8 -*-
require 'rss/2.0'
require 'open-uri'
require 'fileutils'
require 'htmlentities'

# ref: http://rubyrss.com/

open('http://0.0.0.0/fayu.xml') do |http|
  response = http.read
  result = RSS::Parser.parse(response, false)
#  puts "Channel: " + result.channel.title
  result.items.each_with_index do |item, i|
    id = i-600
    title =  item.title.to_s.chomp
    # some item are blank titles
    # we cant allow this, otherwise the following gsub exits if working on a blank string, aka Nil
    # so, fill in some gibberish
    if title == nil
      title = "no title"
    end
    
    mytitle = title

    # pubdae: 2012-02-16T14:36:54+08:00-id
    pubdate = item.date.xmlschema
    # date: 2012-02-16
    date = pubdate.slice(0,10)

    content = item.description.to_s
    content = HTMLEntities.new.decode content    
    content = content.gsub(/\n/, "\n\n")


    content = content.gsub(/^<p> \]\]>/, "")
    content = content.gsub(/<\/p>/, "")
    content = content.gsub(/^<p>nn$>/, "") #这两行得在<p>前面否则这两行白写了 ：）
    content = content.gsub(/^<p>n$/, "")
    content = content.gsub(/<p>/, "")
    content = content.gsub(/<br \/>/, "\n")
    content = content.gsub(/^nn+/, "\n")
    content = content.gsub(/^n/, "\n")
    content = content.gsub(/\n\n+/, "\n\n")
    content = content.gsub(/^ +/, "")

    # get category of posts 
    tags = item.category.to_s
    tags = tags.gsub(/<category>/, "")
    tags = tags.gsub(/<\/category>/, "")

    # read what's been parsed in terminal
    puts mytitle
   
    File.open("#{date}#{id}.markdown", "w:utf-8") do |file|
      file.puts "---"
      file.puts "title: \"#{mytitle}\""
      file.puts "author:"
      file.puts "category: "
      file.puts "tags: "
      file.puts "layout: post"
      file.puts "---"
      file.puts content
    end
  end      # end each_with_index
end # end open('http://0.0.0.0/rss.xml') do |http|


