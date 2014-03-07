# -*- coding: utf-8 -*-

# Load libraries required by the Evernote OAuth sample applications
require 'oauth'
require 'oauth/consumer'

# Load Thrift & Evernote Ruby libraries
require "evernote_oauth"


module EvernoteConfig

  # Client credentials
  # If you do not have an Evernote API key, you may request one
  # from http://dev.evernote.com/documentation/cloud/

  def auth_sandbox
    # If you use a sandbox environment, return true.
    false
  end

  def auth_key
    ENV['EVERNOTE_AUTH_KEY']
  end

  def auth_secret
    ENV['EVERNOTE_AUTH_SECRET']
  end

  def auth_token
    ENV['EVERNOTE_AUTH_TOKEN']
  end

  # Filter notebook
  def reject_notebook?(notebook)
    if /^[34][0-9][0-9]_/ =~ notebook.name
    # if /^4[0-9][0-9]_/ =~ notebook.name
    # if /^424_/ =~ notebook.name
      return false
    else
      return true
    end
  end

  # Filter note
  def reject_note?(note, notebook)
    if /(pdf|ppt|pptx|doc)$/ =~ note.attributes.sourceURL
      return true
    else
      return false
    end
  end

  # Get category strings
  def get_category(notebook,note)
    category_table = {
      "310" => "Tech",
      "311" => "Tech",
      "312" => "Tech",
      "313" => "Tech",
      "314" => "MyStudy",
      "315" => "MyStudy",
      "316" => "MyStudy",
      "317" => "MyStudy",
      "320" => "MyStudy",
      "321" => "MyStudy",
      "330" => "Biz",
      "331" => "Biz",
      "340" => "Life",
      "351" => "Life",
      "410" => "Tech",
      "411" => "Tech",
      "412" => "Tech",
      "413" => "Tech",
      "414" => "Biz",
      "415" => "Life",
      "420" => "MyStudy",
      "421" => "MyStudy",
      "422" => "MyStudy",
      "423" => "MyStudy",
      "424" => "MyStudy",
      "431" => "Biz",
      "433" => "Life",
    }
    category_table[notebook.name[0..2]]
  end
end

