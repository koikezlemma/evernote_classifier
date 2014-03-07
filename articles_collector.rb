# -*- coding: utf-8 -*-

require 'rss'


module ArticlesCollector

  DEFAULT_URLS = [
    'http://rss.rssad.jp/rss/itmenterprise/2.0/ep_all.xml',
    'http://rss.rssad.jp/rss/itmnews/2.0/biz_trends.xml',
    'http://rss.rssad.jp/rss/itmsecurity/2.0/security.xml',
    'http://rss.rssad.jp/rss/itmoshard/2.0/windows.xml',
    'http://rss.rssad.jp/rss/itmplusd/2.0/plusd.xml',
    'http://rss.dailynews.yahoo.co.jp/fc/rss.xml',
    'http://rss.dailynews.yahoo.co.jp/fc/domestic/rss.xml',
    'http://rss.dailynews.yahoo.co.jp/fc/world/rss.xml',
    'http://rss.dailynews.yahoo.co.jp/fc/economy/rss.xml',
    'http://rss.dailynews.yahoo.co.jp/fc/entertainment/rss.xml',
    'http://rss.dailynews.yahoo.co.jp/fc/sports/rss.xml',
    'http://rss.dailynews.yahoo.co.jp/fc/computer/rss.xml',
    'http://rss.dailynews.yahoo.co.jp/fc/science/rss.xml',
    'http://rss.dailynews.yahoo.co.jp/fc/local/rss.xml',
    'http://feed.nikkeibp.co.jp/rss/nikkeibp/subject.rdf',
    'http://feed.nikkeibp.co.jp/rss/nikkeibp/recommend.rdf',
    'http://feed.nikkeibp.co.jp/rss/nikkeibp/buzz.rdf',
    'http://feed.nikkeibp.co.jp/rss/nikkeibp/feature.rdf',
    'http://feed.nikkeibp.co.jp/rss/nikkeibp/business.rdf',
    'http://feed.nikkeibp.co.jp/rss/nikkeibp/it.rdf',
    'http://feed.nikkeibp.co.jp/rss/nikkeibp/pc.rdf',
    'http://www.nikkeibp.co.jp/rss/life.rdf',
    'http://feed.nikkeibp.co.jp/rss/nikkeibp/manufacture.rdf',
    'http://feed.nikkeibp.co.jp/rss/nikkeibp/ecology.rdf',
    'http://feed.nikkeibp.co.jp/rss/nikkeibp/architecture.rdf',
    'http://feed.nikkeibp.co.jp/rss/nikkeibp/medical.rdf',
    'http://feed.nikkeibp.co.jp/rss/nikkeibp/index.rdf',
    'http://feed.nikkeibp.co.jp/rss/nikkeibp/career.rdf',
    'http://cloud.watch.impress.co.jp/cda/rss/cloud.rdf',
    'http://dc.watch.impress.co.jp/cda/rss/digicame.rdf',
    'http://k-tai.impress.co.jp/cda/rss/ktai.rdf',
    'http://internet.watch.impress.co.jp/cda/rss/internet.rdf',
    'http://kaden.watch.impress.co.jp/cda/rss/kaden.rdf',
    'http://jp.techcrunch.com/feed/',
    'http://feeds.gizmodo.jp/rss/gizmodo/index.xml',
    'http://feed.rssad.jp/rss/nikkansports/baseball/index.rdf',
    'http://feed.rssad.jp/rss/nikkansports/baseball/mlb/index.rdf',
    'http://feed.rssad.jp/rss/nikkansports/soccer/index.rdf',
    'http://feed.rssad.jp/rss/nikkansports/soccer/japan/index.rdf',
    'http://feed.rssad.jp/rss/nikkansports/soccer/world/index.rdf',
    'http://feed.rssad.jp/rss/nikkansports/entertainment/index.rdf',
    'http://feed.rssad.jp/rss/nikkansports/general/index.rdf',
  ]

  module_function

  def collect_articles(urls = DEFAULT_URLS)
    articles = []
    urls.each do |url|
      begin
        rss = RSS::Parser.parse(url)
      rescue RSS::InvalidRSSError
        rss = RSS::Parser.parse(url, false)
      end
      rss.items.each do |item|
        if item.respond_to?(:title) && item.respond_to?(:link) && item.respond_to?(:description) then
          articles.push({title:item.title, link:item.link, desc:item.description})
        end
      end
    end
    return articles
  end
end

