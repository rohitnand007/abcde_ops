class ContentInformation < ApplicationRecord
  self.table_name = "files"
  validates_uniqueness_of :content_guid, scope: :content_type

  def self.get_not_uploaded_books_list
    path = ENV['HOST_URL'] + "/api/ops/content_request/" + "request_not_uploaded_books?key=" + ENV['TOKEN']
    response = open(path,:read_timeout => 300).read
    book_asset_info = JSON.parse(response)["book_asset_info"]
    content_ids = []
    book_asset_info.each do |ba_info|
      content_ids << file_model_before_upload(ba_info)
    end
    get_book_content
  end

  def self.get_book_content
    download_content_list = ContentInformation.where(download_status:"failed")
      download_content_list.each do |ba_info|
       ba_info.update_attribute(:download_status,"in_delayed_job")
       ba_info.get_book_content_process
      end
  end

  def get_book_content_process
    self.update_attribute(:download_status, "in_progress")
    books_md5_hash = {}
    dir_path = self.create_required_directory(self.content_id, self.content_type, self.url)
    if self.content_type == "book"
      saved_file_dest_path = self.fetch_book_encrypted_file(self.content_id, dir_path)
    elsif self.content_type == "book_info"
      saved_file_dest_path = self.fetch_book_info_file(self.content_id, dir_path)
    else
      saved_file_dest_path = self.fetch_content_file(self.url, self.filename, dir_path)
    end
    puts "#{saved_file_dest_path}"
    #---------------------------------------------------------------------#
    unless self.content_type == "book_info"
      md5_hash = self.calculate_md5_hash(saved_file_dest_path)
      # books_md5[ba_info[-4]] = md5_hash
      books_md5_hash[self.content_guid] = md5_hash
      puts books_md5_hash.to_json
      download_status = self.send_books_md5_hash(books_md5_hash.to_json)
      puts download_status
      self.file_model_after_upload(self.url, saved_file_dest_path.gsub(ENV['CONTENT_DIR'],""), download_status)
    else
      download_status = "success"
      self.file_model_after_upload(self.url, saved_file_dest_path.gsub(ENV['CONTENT_DIR'],""), download_status)
    end
  end
  handle_asynchronously :get_book_content_process

  def create_required_directory(content_id, type, url)
    if type == "book"
      dir_path = ENV['CONTENT_DIR'] + "/ibook_assets/" + "#{content_id}" + "/encrypted_content"
    elsif type == "book_info"
      dir_path = ENV['CONTENT_DIR'] + "/ibook_assets/" + "#{content_id}" + "/info_files"
    elsif type == "asset"
      dir_path =  ENV['CONTENT_DIR'] + "/system/user_assets/attachments/" + "#{content_id}"
    elsif type == "quiz"
      f_url = url.split("/")
      f_url.pop
      #dir_path = "/home/rahul/work/cachefiles" + "/public" + f_url.inject(""){|s,x| s+ "/" + x} #"/messages/44572/1489495957"
      dir_path = ENV['CONTENT_DIR'] + f_url.inject(""){|s,x| s+ "/" + x} #"/messages/44572/1489495957"
    end
    dir_create = self.directory_create(dir_path)
    puts "destination directory created"
    return dir_path
  end

  #since FileUtlis is now onlyy supported for ruby 2.5 and above anf all prev versions have been yanked
  def directory_create(path)
    recursive = path.split('/')
    directory = ''
    recursive.each do |sub_directory|
      directory += sub_directory + '/'
      Dir.mkdir(directory) unless (File.directory? directory)
    end
  end

  def fetch_book_encrypted_file(book_id, dir_path)
    path = ENV['HOST_URL'] + "/api/ops/content_request/" + "send_ibook_file?key=" + ENV['TOKEN'] + "&book_id=#{book_id}"
    filename = "encrypted.zip"
    dest_path = dir_path + "/#{filename}"
    response = open(path,:read_timeout => 300)
    dest_file = IO.copy_stream(response, dest_path)
    puts "file saved to directory"
    return dest_path
  end

  def fetch_book_info_file(book_id, dir_path)
    path = ENV['HOST_URL'] + "/api/ops/content_request/" + "send_ibook_info_file?key=" + ENV['TOKEN'] + "&book_id=#{book_id}"
    filename = "info.zip"
    dest_path = dir_path + "/#{filename}"
    response = open(path,:read_timeout => 300)
    dest_file = IO.copy_stream(response, dest_path)
    puts "info_file saved to directory"
    return dest_path
  end

  def fetch_content_file(hit_url, filename, dir_path)
    content_url = ENV['HOST_URL'] + "/#{hit_url}"
    response = open(content_url, :read_timeout => 300)
    dest_path = dir_path + "/#{filename}"
    dest_file = IO.copy_stream(response, dest_path)
    puts "asset saved in the dirrr"
    return dest_path
  end

  def calculate_md5_hash(content_url)
    md5_hash = Digest::MD5.file content_url
    md5_digest = md5_hash.hexdigest
    puts "md5 hash calculated"
    return md5_digest
  end

  def send_books_md5_hash(books_md5_hash)
    path = ENV['HOST_URL'] + "/api/ops/content_request/" + "update_cdn_content_status?key=" + ENV['TOKEN']
    url = URI.parse(path)
    resp, data = Net::HTTP.post_form(url,book_md5:books_md5_hash)
    puts resp
    puts resp.body
    puts data
    status = JSON.parse(resp.body)["status"][0]
    return status
  end

  def self.file_model_before_upload(info_arr)
    @content_info = ContentInformation.where(content_guid: info_arr[7], content_type:info_arr[9]).first
    if (@content_info.present? and @content_info.download_status == "success")
      @content_info.update_attributes(is_sync:"n", download_status:"failed") unless @content_info.nil?
    end
    if @content_info.nil?
      @content_info = ContentInformation.new
      @content_info.url = info_arr[0]
      @content_info.filename = info_arr[1]
      @content_info.relativefilepath = info_arr[2]
      @content_info.file_md5 = info_arr[3]
      @content_info.url_md5 = info_arr[4]
      @content_info.is_sync = info_arr[5]
      @content_info.date_created = info_arr[6].to_time
      @content_info.content_type = info_arr[-2]
      @content_info.content_guid = info_arr[7]
      @content_info.download_status = info_arr[8]
      @content_info.content_id = info_arr[-1]
      @content_info.save
    end
    return @content_info.url
  end

  def file_model_after_upload(info_id, relativefilepath, download_status)
    c_info = ContentInformation.find(info_id)
    download_status == "success" ? c_info.update_attributes(is_sync:"y", download_status:download_status, relativefilepath: relativefilepath) : c_info.update_attributes(is_sync:"n", download_status:download_status, relativefilepath: relativefilepath)
  end
end
