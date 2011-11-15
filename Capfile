#!/usr/bin/env ruby

require 'etc'
require 'json'
require 'alpha_omega/deploy'

ssh_options[:forward_agent] = true

set :application, "mmtop"
set :repository, "git@github.com:osheroff/mmtop.git"
set :releases, [ "#{application}_alpha" ]
set :current_dir, application

set :user, "zendesk"
set :group, "zendesk"
set :deploy_to, "/data"

# branches and hosts
set :branch, AlphaOmega.what_branch

hosts =
  AlphaOmega.what_hosts '/data/zendesk_chef/nodes/*.json' do |node|
    if node[:node_name] && node["public_ip"]
      node_task = node[:node_name].to_sym
      task node_task do
        role node_task, node[:node_name]
      end
    end
  end

groups =
  AlphaOmega.what_groups hosts do |nm_group, group|
    task nm_group.to_sym do
      group.keys.sort.each do |nm_node|
        role nm_node.to_sym, nm_node
      end
    end
  end

# ruby
set :ruby_env, "/data/zendesk/config/ree.env"
set :ruby_rvm, "/usr/local/lib/rvm"

namespace :deploy do
  task :symlink do
    run "ln -sf /data/releases/mmtop_alpha/mmtop.rb /data/zendesk/bin/"
  end
end


before "deploy:update_code","deploy:lock"
after "deploy:update_code","ruby:bundle","deploy:symlink"
