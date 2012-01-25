# I'd like to say that I no longer understand this code.
# Also, I'd like to say that it's unlikely to work for you, the general public.  patches welcome!

module MMTop
  class Topology
    def initialize(config)
      @config = config
    end

    def new_hostlist
      topology = find_master_slave
      topology.each { |name, t| fill_chain_info(t, topology) }

      new_top = create_sort_array(topology)

      hosts = @config.hosts.sort_by { |h| new_top.find_index { |t| t[:hostname] == h.name } }
      hosts.each { |h|
        top = new_top.find { |t| t[:hostname] == h.name }
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
        v[:master] == host[:hostname] 
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

      if last_master
       host[:final_master] = last_master[:hostname] 
      else
       host[:final_master] = host[:hostname]
      end
      host[:levels] = levels
    end

    def find_master_slave
      topology = @config.hosts.inject({}) { |accum, h|
        hostname = h.query("show global variables where Variable_name='hostname'")[0][:Value]
        hostname = hostname.split('.')[0]
        status = h.slave_status

        if status && status[:Master_User] != 'test'
          master_host = status[:Master_Host]
        end

        master_host = short_name_for_host(master_host) if master_host

        accum[hostname] = {:master => master_host, :hostname => hostname}
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

    def short_name_for_host(h)
      if h =~ /\d+.\d+.\d+.\d+/
        h = ip_to_short_hostname(h)
      end
      h.split('.')[0]
    end

    def ip_to_short_hostname(ip)
      `grep #{ip} /etc/hosts | awk '{print $2}'`.chomp
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
