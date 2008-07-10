module Multipart
  # From: http://deftcode.com/code/flickr_upload/multipartpost.rb
  ## Helper class to prepare an HTTP POST request with a file upload
  ## Mostly taken from
  #http://blade.nagaokaut.ac.jp/cgi-bin/scat.rb/ruby/ruby-talk/113774
  ### WAS:
  ## Anything that's broken and wrong probably the fault of Bill Stilwell
  ##(bill@marginalia.org)
  ### NOW:
  ## Everything wrong is due to keith@oreilly.com

  require 'mime/types'
  require 'net/http'

  class Param
    attr_accessor :k, :v
    def initialize( k, v )
      @k = k
      @v = v
    end

    def to_multipart
      "Content-Disposition: form-data; name=\"#{k}\"\r\n\r\n#{v}\r\n"
    end
  end

  class FileParam
    attr_accessor :k, :filename, :content
    def initialize( k, file )
      @k = k
      @filename = file.path
      @content = file.read
      @content_type = file.content_type rescue nil
    end

    def to_multipart
      "Content-Disposition: form-data; name=\"#{k}\"; filename=\"#{filename}\"\r\n" + "Content-Transfer-Encoding: binary\r\n" + "Content-Type: #{@content_type || MIME::Types.type_for(@filename)}\r\n\r\n" + content + "\r\n"
    end
  end

  class Post
    BOUNDARY = 'tarsiers-rule0000'
    HEADER = {"Content-type" => "multipart/form-data, boundary=" + BOUNDARY + " "}

    def self.prepare_query (params)
      fp = []
      params.each {|k,v|
        if v.respond_to?(:read)
          fp.push(FileParam.new(k, v))
        else
          fp.push(Param.new(k,v))
        end
      }
      query = fp.collect {|p| "--" + BOUNDARY + "\r\n" + p.to_multipart }.join("") + "--" + BOUNDARY + "--"
      return query, HEADER
    end
  end  
end
