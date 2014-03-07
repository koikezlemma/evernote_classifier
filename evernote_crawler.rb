# -*- coding: utf-8 -*-

require_relative "evernote_config.rb"

class EvernoteCrawler
  include EvernoteConfig

  def initialize
    # Verify that you have obtained an Evernote API key
    raise "Set Evernote API key." if auth_key.nil? || auth_secret.nil? || auth_token.nil?
  end

  def client
    begin
      @client ||= EvernoteOAuth::Client.new(token: auth_token, consumer_key: auth_key, consumer_secret: auth_secret, sandbox: auth_sandbox)
    rescue => e
      $stderr.puts "Failed to init client: #{Evernote::EDAM::Error::EDAMErrorCode::VALUE_MAP[e.errorCode]}"
    end
  end

  def user_store
    @user_store ||= client.user_store
  end

  def note_store
    @note_store ||= client.note_store
  end

  def user
    begin
      @user ||= user_store.getUser(auth_token)
    rescue => e
      $stderr.puts "Failed to get User: #{Evernote::EDAM::Error::EDAMErrorCode::VALUE_MAP[e.errorCode]}"
      if e.errorCode == Evernote::EDAM::Error::EDAMErrorCode::RATE_LIMIT_REACHED then
        $stderr.puts "Retry getUser after #{e.rateLimitDuration} seconds"
        sleep(e.rateLimitDuration)
        $stderr.puts "Retry getUser now"
        begin
          @user = user_store.getUser(auth_token)
        rescue => e
          $stderr.puts "Failed to get User: #{Evernote::EDAM::Error::EDAMErrorCode::VALUE_MAP[e.errorCode]}"
        end
      end
    end
  end

  def notebooks
    begin
      @notebooks ||= note_store.listNotebooks(auth_token)
    rescue => e
      $stderr.puts "Failed to list Notebooks: #{Evernote::EDAM::Error::EDAMErrorCode::VALUE_MAP[e.errorCode]}"
      if e.errorCode == Evernote::EDAM::Error::EDAMErrorCode::RATE_LIMIT_REACHED then
        $stderr.puts "Retry listNotebooks after #{e.rateLimitDuration} seconds"
        sleep(e.rateLimitDuration)
        $stderr.puts "Retry listNotebooks now"
        begin
          @notebooks = note_store.listNotebooks(auth_token)
        rescue => e
          $stderr.puts "Failed to list Notebooks: #{Evernote::EDAM::Error::EDAMErrorCode::VALUE_MAP[e.errorCode]}"
        end
      end
    end
  end

  def get_notes
    my_notes = []
    notebooks.each do |notebook|
      next if reject_notebook?(notebook)
      filter = Evernote::EDAM::NoteStore::NoteFilter.new
      filter.notebookGuid = notebook.guid
      result_spec = Evernote::EDAM::NoteStore::NotesMetadataResultSpec.new
      result_spec.includeTitle = true
      result_spec.includeAttributes = true
      begin
        note_list = note_store.findNotesMetadata(auth_token, filter, 0, 1000, result_spec)
      rescue => e
        $stderr.puts "Failed to get notes meta data: #{Evernote::EDAM::Error::EDAMErrorCode::VALUE_MAP[e.errorCode]}"
        if e.errorCode == Evernote::EDAM::Error::EDAMErrorCode::RATE_LIMIT_REACHED then
          $stderr.puts "Retry findNotesMetadata after #{e.rateLimitDuration} seconds"
          sleep(e.rateLimitDuration)
          $stderr.puts "Retry findNotesMetadata now"
          begin
            note_list = note_store.findNotesMetadata(auth_token, filter, 0, 1000, result_spec)
          rescue => e
            $stderr.puts "Failed to get notes meta data: #{Evernote::EDAM::Error::EDAMErrorCode::VALUE_MAP[e.errorCode]}"
          end
        end
      end
      note_list.notes.each do |note|
        next if reject_note?(note, notebook)
        begin
          note_content = note_store.getNoteContent(auth_token, note.guid)
        rescue => e
          $stderr.puts "Failed to get note content: #{Evernote::EDAM::Error::EDAMErrorCode::VALUE_MAP[e.errorCode]}"
          if e.errorCode == Evernote::EDAM::Error::EDAMErrorCode::RATE_LIMIT_REACHED then
            $stderr.puts "Retry getNoteContent after #{e.rateLimitDuration} seconds"
            sleep(e.rateLimitDuration)
            $stderr.puts "Retry getNoteContent now"
            begin
              note_content = note_store.getNoteContent(auth_token, note.guid)
            rescue => e
              $stderr.puts "Failed to get note content: #{Evernote::EDAM::Error::EDAMErrorCode::VALUE_MAP[e.errorCode]}"
              note_content = ""
            end
          end
        end
        category = get_category(notebook, note)
        my_notes.push({cat: category, url: note.attributes.sourceURL, title: note.title, content: note_content}) if category
      end
    end
    return my_notes
  end
end

