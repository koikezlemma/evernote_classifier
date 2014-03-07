# -*- coding: utf-8 -*-

require 'nokogiri'

require_relative 'json_generator.rb'
require_relative 'bayes_classifier.rb'

# Training
classifier = BayesClassifier.new
url_list = JsonGenerator.read_json('notes.json')
url_list.each do |item|
  content = item[:title]
  if item[:content]
    begin
      doc = Nokogiri::Slop(item[:content])
      content += " " + doc.content
    rescue => e
      $stderr.puts "Failed to parse XML: #{e.message}"
    end
  end
  begin
    classifier.train(content, item[:cat])
  rescue => e
    $stderr.puts "Failed to train: #{e.message}"
  end
end
classifier.generate_json('classifier.json')
