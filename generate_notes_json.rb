# -*- coding: utf-8 -*-

require_relative 'evernote_crawler.rb'
require_relative 'json_generator.rb'


begin
  crawler = EvernoteCrawler.new
rescue => e
  $stderr.puts "Failed to create a crawler: #{e.message}"
  exit
end
begin
  notes = crawler.get_notes
rescue => e
  $stderr.puts "Failed to get note list: #{e.message}"
  exit
end

JsonGenerator.generate_json(notes, 'notes.json')
