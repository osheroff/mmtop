module MMTop
  class ReverseLookup
    def self.lookup(client)
      return client if client.nil? or client.empty?
      return client unless client =~ /\d+\.\d+\.\d+\.\d+/

      @@lookups = {}
      split  = client.split(':')
      client = split[0]

      return @@lookups[client] + ":" + split[1] if @@lookups[client]

      hostline = %x{dig -x #{client} +short}
      hostline.gsub!(/([^\.]+)\./, '\1')
      @@lookups[client] = hostline
      @@lookups[client] + ":" + split[1]
    end
  end
end

Filter.add_filter("reverse_lookup") do |queries|
  queries.each do |q|
    q.host = MMTop::ReverseLookup.lookup(q.host)
  end
end
