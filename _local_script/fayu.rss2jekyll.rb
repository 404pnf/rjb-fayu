# -*- coding: utf-8 -*-
require 'rss/2.0'
require 'open-uri'
require 'fileutils'
require 'yaml'
require 'kramdown'
require 'html2markdown'
# ref: http://rubyrss.com/

file = ARGV[0]
output = ARGV[1]
Dir.mkdir(output) if !File.exist?(output)
def sanitize(title)
  # tr! 返回 nil 如果没有任何修改，因此也不要使用
  title = title.tr(' `~!@#$%^&*()_+=\|][{}"\';:/?.>,<', '_')
  title = title.tr('－·～！@#￥%……&*（）——+、|】』【『‘“”；：/？。》，《', '_')
  title = title.gsub(/_+/, '_').gsub(/^_/, '').gsub(/_$/, '') # 对开头，结尾和多个 _ 做处理
  # 谨慎使用gsbu!
  # !!!!! gsub!的返回值是修改了的str或者nil，如果没有做任何修改的话就是nil
  # 因此最后需要再直接调一下title让本函数最后的输出是title本身的值 
  # 这个bug困惑了好久好久啊！！
  # gsub!(pattern) → an_enumerator
  # Performs the substitutions of String#gsub in place, 
  # returning str, or nil if no substitutions were performed. 
end

File.open(file) do |f|
  response = f.read
  result = RSS::Parser.parse(response, false) # false 是说不去validate rss

#  puts "Channel: " + result.channel.title
  result.items.each do |item|
    title = item.title.to_s.strip
    mytitle = sanitize(title).gsub(/_/, ' ')
    #    p mytitle
    fn = sanitize(mytitle)
    #   p fn
    # pubdae: 2012-02-16T14:36:54+08:00-id
    pubdate = item.date.xmlschema
    # date: 2012-02-16
    date = pubdate.slice(0,10)

    content = item.description.to_s
    content = content.gsub(/\n/,"\n\n").gsub(/\n\n\n+/,"\n\n")
    raw_html = HTMLPage.new :contents => content
    content = raw_html.markdown
    content = content.gsub(/^n/, '').gsub(']]>', '').gsub('![]()', '')
    content = content.gsub(/\n/,"\n\n").gsub(/\n\n\n+/,"\n\n").gsub(/^ +/, '').gsub(/^n/, '')
    #    p content
    # Get the relevant fields as a hash, delete empty fields and convert
    # to YAML for the header
    data = {
    'layout' => 'post',
    'title' => mytitle.to_s,
    }.delete_if { |k,v| v.nil? || v == ''}.to_yaml

   
    File.open("#{output}/#{date}-#{fn}.markdown", "w:utf-8") do |file|
      file.puts data
      file.puts "---"
      file.puts
      file.puts content
    end

  end      # end each_with_index
end # end open('http://0.0.0.0/rss.xml') do |http|


