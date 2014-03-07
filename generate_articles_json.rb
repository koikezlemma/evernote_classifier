# -*- coding: utf-8 -*-

require_relative 'articles_collector.rb'
require_relative 'json_generator.rb'

articles = ArticlesCollector.collect_articles
JsonGenerator.generate_json(articles, 'articles.json')
