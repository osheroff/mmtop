module MMTop
  class ReverseLookup
    def self.lookup(client)
      return client if client.nil? or client.empty?
      return client unless client =~ /\d+\.\d+\.\d+\.\d+/

      @@lookups ||= {}

      return @@lookups[client] if @@lookups[client]

      hostline = %x{dig -x #{client} +short}.split("\n").first.to_s
      hostline = hostline.gsub(/([^\.]+)\..*/, '\1')
      if hostline.empty?
        @@lookups[client] = client
      else
        @@lookups[client] = hostline
      end

      @@lookups[client] 
    end
  end

  Filter.add_filter("reverse_lookup") do |queries|
    queries.each do |q|
      q.client = MMTop::ReverseLookup.lookup(q.client)
    end
  end
end

