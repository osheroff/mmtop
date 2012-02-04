# I'd like to say that I no longer understand this code.
# Also, I'd like to say that it's unlikely to work for you, the general public.  patches welcome!
require 'socket'

module MMTop
  class Topology
    def initialize(config)
      @config = config
    end

    def new_hostlist
      topology = find_master_slave
      topology.each { |name, t| fill_chain_info(t, topology) }

      new_top = create_sort_array(topology)

      hosts = @config.hosts.sort_by { |h| new_top.find_index { |t| t[:hostname] == h.name } || 1_000_000 }
      hosts.each { |h|
        top = new_top.find { |t| t[:hostname] == h.name }
        next unless top
        if top[:levels] > 0
          h.display_name = ("  " * top[:levels]) + '\_' + h.name
        end
      }
      hosts
    end

    def insert_host_into_sort_array(t, host, array)
      array << host
      t.select { |k, v|
        # find hosts who are our slaves
        v[:master] == host[:ip]
      }.sort_by { |k, v|
        # add those without children of their own first
        v[:is_master].to_i
      }.each { |k, s|
        insert_host_into_sort_array(t, s, array)
      }
      array
    end


    def create_sort_array(t)
      array = []
      t.values.select { |v|
        v[:levels] == 0
      }.sort_by { |v|
        v[:hostname]
      }.each { |v|
        insert_host_into_sort_array(t, v, array)
      }
      array
    end

    def fill_chain_info(host, topology)
      levels = 0
      stack = []
      master = host
      while master = topology[master[:master]]
        # loop detection
        break if stack.include?(master)

        last_master = master
        levels += 1
        stack.push(master)
      end

      host[:levels] = levels
    end

    def resolve_to_ip(hostname)
      return nil if hostname.nil?
      return hostname if hostname =~ /\d+\.\d+\.\d+\.\d+\./

      arr = Socket::gethostbyname(hostname)
      arr && arr.last.unpack("CCCC").join(".")
    end

    def find_master_slave
      @config.hosts.each { |host|
        host.ip = resolve_to_ip(host.name)
      }

      topology = @config.hosts.inject({}) { |accum, h|
        next unless h.ip

        status = h.slave_status

        if status && status[:Master_User] != 'test'
          master_host = status[:Master_Host]
        end

        master_host = resolve_to_ip(master_host)

        accum[h.ip] = {:master => master_host, :hostname => h.name, :ip => h.ip}
        accum
      }

      # fill in :is_master
      topology.each { |k, v|
        master_top = topology[v[:master]]
        if master_top
          master_top[:is_master] = 1
        end
      }
      topology
    end
  end

  Filter.add_filter("discover_topology") do |queries, hostinfo, config|
    if config.options['discover_topology'] && !config.options['topology.discovered']
      config.options['topology.discovered'] = true
      config.hosts = MMTop::Topology.new(config).new_hostlist
    end
  end

  MMTop::Command.register do |c|
    c.regexp /map_topology/
    c.usage "map_topology"
    c.explain "Re-Map the slave-chain topology"
    c.command do |cmd, config|
      config.options['discovered'] = false
    end
  end
end
