module Requestify
  private
    # Taken from ActionController::Integration::Session and patched to use map_with_index
    #
    def name_with_prefix(prefix, name)
      prefix ? "#{prefix}[#{name}]" : name.to_s
    end

    def requestify(parameters, prefix=nil)
      if Hash === parameters
        return nil if parameters.empty?
        parameters.map { |k,v| requestify(v, name_with_prefix(prefix, k)) }.join("&")
      elsif Array === parameters
        parameters.map_with_index { |v,i| requestify(v, name_with_prefix(prefix, i)) }.join("&")
      elsif prefix.nil?
        parameters
      else
        #"#{prefix}=#{parameters.to_s}"
        "#{CGI.escape(prefix)}=#{CGI.escape(parameters.to_s)}"
      end
    end
end
