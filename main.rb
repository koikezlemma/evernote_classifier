# -*- coding: utf-8 -*-

require 'sinatra'

require_relative 'bayes_classifier.rb'
require_relative 'articles_collector.rb'
require_relative 'json_generator.rb'

get '/' do
  contents = JsonGenerator.read_json('contents.json')
  erb :index, :locals => {:contents => contents}
end

get '/update' do
  articles = ArticlesCollector.collect_articles
  JsonGenerator.generate_json(articles, 'articles.json')
  classifier = BayesClassifier.new('classifier.json')
  contents = classifier.classify_articles(articles)
  JsonGenerator.generate_json(contents, 'contents.json')
  redirect '/'
end

get '/stored' do
  contents = JsonGenerator.read_json('contents_sample.json')
  erb :index, :locals => {:contents => contents}
end


__END__

@@ index
<!DOCTYPE html>
<html>
<head>

  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width">

  <title>Evernote classifier</title>
  <link rel="stylesheet" href="http://code.jquery.com/mobile/1.3.2/jquery.mobile-1.3.2.min.css" />
  <script src="http://code.jquery.com/jquery-1.9.1.min.js"></script>
  <script src="http://code.jquery.com/mobile/1.3.2/jquery.mobile-1.3.2.min.js"></script>

  <style>
  .wordbreak{
    overflow: visible;
    white-space: normal;
  }
  </style>
</head>

<body>
<div data-role="page" id="index" data-theme="e">

<!-- ********** Header ********************* -->
<div data-role="header">
  <h1>Evernote classifier</h1>
</div>
<!-- ********** Content ******************** -->
<div data-role="content">
  <% contents.each do |cat, list| %>
  <ul data-role="listview" data-inset="true">
    <li data-role="list-divider"><%= cat %></li>
    <% item_count = 0 %>
    <% list.each do |item| %>
      <% break if item_count >= 5; item_count += 1 %>
    <li><a href="<%= item[:link] %>"><p class="wordbreak"><%= item[:title] %></p>
      <p class="ui-li-aside">Probability: <%= sprintf("%.2f", item[:score]) %></p></a></li>
    <% end %>
  </ul>
  <% end %>
</div>
<!-- ********** Footer ********************* -->
<div data-role="footer">
  <h1>Evernote classifier</h1>
</div>

</div>

</body>
</html>
