# -*- coding: utf-8 -*-

require 'json'


module JsonGenerator
  module_function

  def generate_json(item_list, file_name)
    open(File.dirname(__FILE__) + '/' + file_name, "w") do |io|
      io.write(JSON.pretty_generate(item_list))
    end
  end

  def read_json(file_name)
    item_list = []
    open(File.dirname(__FILE__) + '/' + file_name,'r') do |io|
      item_list = JSON.parse(io.read, { symbolize_names: true })
    end
  end
end
