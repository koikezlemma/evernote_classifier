# -*- coding: utf-8 -*-

require 'MeCab'


class BayesClassifier
  def train(doc, cat)
    bag_of_words = get_bag_of_words(doc)
    bag_of_words.each do |word, count|
      num_words[cat] ||= {}
      num_words[cat][word] ||= 0
      num_words[cat][word] += count
      num_ok_docs[cat] ||= {}
      num_ok_docs[cat][word] ||= 0
      num_ok_docs[cat][word] += 1
      vocablaries.push(word) unless vocablaries.include?(word)
    end
    num_total_docs[cat] ||= 0
    num_total_docs[cat] += 1
  end

  # Classify a document
  # model: 'multinomial' or 'bernoulli'
  def classify(doc, model='multinomial')
    cat_opt = nil
    score_opt = -1.0 / 0.0
    bag_of_words = get_bag_of_words(doc)
    sum_total_docs = num_total_docs.values.inject(0, &:+)
    sum_total_words = {}
    num_words.each do |cat,num|
      sum_total_words[cat] = num.values.inject(0, &:+)
    end

    score = {}
    num_total_docs.keys.each do |cat|
      score[cat] = score(bag_of_words, cat, sum_total_docs, sum_total_words, model)
      if score[cat] > score_opt
        score_opt = score[cat]
        cat_opt = cat
      end
    end
    prob = 0
    num_total_docs.keys.each do |cat|
      prob += Math.exp(score[cat]-score[cat_opt])
    end
    prob = 1 / prob

    return {cat:cat_opt, score:prob}
  end

  # Classify a set of documents
  # model: 'multinomial' or 'bernoulli'
  def classify_articles(articles, model='multinomial')
    contents = {}
    # Delete duplication
    articles_sort = articles.sort { |x1, x2| x1[:title] <=> x2[:title] }
    1.upto(articles_sort.length - 1).each do |i|
      if articles_sort[i][:title] == articles_sort[i-1][:title] then
        articles_sort[i-1][:title] = ""
      end
    end
    # Classify articles
    articles_sort.each do |item|
      next unless item[:title]
      next if item[:title].length < 2
      next if /^PR/ =~ item[:title]
      doc = item[:title]
      doc += " " + item[:desc] if item[:desc]
      result = classify(doc, model)
      contents[result[:cat].to_sym] ||= []
      contents[result[:cat].to_sym].push({score:result[:score], title:item[:title], link:item[:link]})
    end
    contents.each do |cat, list|
      list.sort! { |x1, x2| x2[:score] <=> x1[:score] }
    end
    return contents
  end

  def generate_json(file_name)
    open(File.dirname(__FILE__) + '/' + file_name, "w") do |io|
      io.write(JSON.pretty_generate(param))
    end
  end

  def read_json(file_name)
    @param ||= {}
    open(File.dirname(__FILE__) + '/' + file_name,'r') do |io|
      @param = JSON.parse(io.read)
    end
  end

  private
  def initialize(json_file_name = nil)
    read_json(json_file_name) if json_file_name
  end

  def param
    @param ||= {}
  end

  # n_{w,c}: #words in category c
  def num_words
    param["num_words"] ||= {}
  end

  # N_{w,c}: #words in category c
  def num_ok_docs
    param["num_ok_docs"] ||= {}
  end

  # Nc  : #docs in category c
  def num_total_docs
    param["num_total_docs"] ||= {}
  end

  # for |w| in total
  def vocablaries
    param["vocablaries"] ||= []
  end

  def get_bag_of_words(doc)
    bag_of_words = {}
    return bag_of_words unless doc
    @mecab ||= MeCab::Tagger.new
    node = @mecab.parseToNode(doc)
    node = node.next
    until node.feature.include?("BOS/EOS")
      # MeCabには形容動詞は無い模様だが念のため入れておく
      if /^(形容詞|形容動詞|感動詞|副詞|連体詞|名詞|動詞)/ =~ node.feature then
        unless stop_word?(node.surface)
          bag_of_words[node.surface] ||= 0
          bag_of_words[node.surface] += 1
        end
      end
      node = node.next
    end
    return bag_of_words
  end

  # n_{w,c}: #words in category c
  def get_num_words(word, cat)
    if num_words[cat][word] then
      return num_words[cat][word]
    else
      return 0
    end
  end

  # N_{w,c}: #docs that includes word w in category c
  def get_num_ok_docs(word, cat)
    if num_ok_docs[cat][word] then
      return num_ok_docs[cat][word]
    else
      return 0
    end
  end

  # Nc  : #docs in category c
  def get_num_total_docs(cat)
    if num_total_docs[cat] then
      return num_total_docs[cat]
    else
      return 0
    end
  end

  # p_c: probability for category
  def prob_category(cat, sum_total_docs, model)
    (get_num_total_docs(cat) + 1.0) / (sum_total_docs + num_total_docs.size)
  end

  # p_{w,c}
  def prob_word(word, cat, sum_total_words, model)
    if model == 'bernoulli' then
      (get_num_ok_docs(word, cat) + 1.0) / (get_num_total_docs(cat) + 2.0)
    elsif model == 'multinomial' then
      (get_num_words(word, cat) + 1.0) / (sum_total_words[cat] + vocablaries.size)
    else
      raise "Unsupported model"
    end
  end

  def score(bag_of_words, cat, sum_total_docs, sum_total_words, model)
    score = Math.log(prob_category(cat, sum_total_docs, model))
    if model == 'bernoulli' then
      vocablaries.each do |word|
        if bag_of_words.keys.include? (word)
          score += Math.log(prob_word(word, cat, sum_total_words, model))
        else
          score += Math.log(1 - prob_word(word, cat, sum_total_words, model))
        end
      end
    elsif model == 'multinomial' then
      bag_of_words.each do |word, count|
        count.times do
          score += Math.log(prob_word(word, cat, sum_total_words, model))
        end
      end
    else
      raise "Unsupported model"
    end
    return score
  end

  def stop_word?(word)
    return true if /^[0-9a-z!"#\$%&'\(\)=\-\^~\¥\|@`\[\]\{\};\+:\*,<\.>\/\?_【】＜＞！”＃＄％＆’（）ー＾￥＠「；：」，．・＿＝〜｜｀『＋＊』＜＞？＿｛｝１２３４５６７８９０①②③④⑤⑥⑦⑧⑨　。、※○●◎]*$/ =~ word
    return false
  end
end


