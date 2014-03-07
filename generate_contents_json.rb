# -*- coding: utf-8 -*-

require_relative 'bayes_classifier.rb'
require_relative 'json_generator.rb'

# Init classifier
classifier = BayesClassifier.new('classifier.json')
# Read articles
articles = JsonGenerator.read_json('articles.json')
# Classify
contents = classifier.classify_articles(articles)
# Generate json
JsonGenerator.generate_json(contents, 'contents.json')
