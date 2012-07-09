# -*- coding: utf-8 -*-
require 'rss/2.0'
require 'open-uri'
require 'fileutils'
require 'yaml'
# ref: http://rubyrss.com/

#FileUtils.mkdir "_posts"

open('http://0.0.0.0/hanyu.xml') do |http|
  response = http.read
  result = RSS::Parser.parse(response, false) # false 是说不去validate rss

#  puts "Channel: " + result.channel.title
  title = ''
  result.items.each_with_index do |item, i|
    id = i-4000
    title = item.title.to_s.strip
    mytitle = title
    mytitle=title.gsub('http://', '') # first one is mytitle=title.
    # yaml中特殊字符都需要过滤调！ http://www.yaml.org/refcard.html
    mytitle=mytitle.gsub(/[*\[\]{}:"$^()'#<>\-%&：；！？（）=，,?! 《》\/|]/, ' ') # works
    mytitle = mytitle.gsub(/ +/, ' ')
    # fn is filename
    fn = mytitle.gsub(/ /, '_')
    fn = mytitle.gsub(/^_/, '')
    fn = fn.gsub(/ +/, '_')
    fn = fn.gsub(/_+/, '_')
    fn = fn.gsub(/_$/, '') # 结尾是 _ 的替换掉
    fn = fn.gsub(/^_/, '-') #  开头是 _ 的替换掉开始的 _
    fn = fn.strip.slice(0,80)

    # pubdae: 2012-02-16T14:36:54+08:00-id
    pubdate = item.date.xmlschema
    # date: 2012-02-16
    date = pubdate.slice(0,10)

    content = item.description.to_s

 # Get the relevant fields as a hash, delete empty fields and convert
  # to YAML for the header
    data = {
    'layout' => 'post',
    'title' => mytitle.to_s,
    }.delete_if { |k,v| v.nil? || v == ''}.to_yaml

   
    File.open("#{date}-#{fn}.markdown", "w:utf-8") do |file|
      file.puts data
      file.puts "---"
      file.puts
      file.puts content
    end

  end      # end each_with_index

end # end open('http://0.0.0.0/rss.xml') do |http|


