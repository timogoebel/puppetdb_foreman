module PuppetdbForeman
  class NodesController < ApplicationController
    before_action :find_node, :only => [:destroy]

    def controller_permission
      'puppetdb_nodes'
    end

    def index
      @foreman_hosts = Host.unscoped.pluck(:name)
      @puppetdb_hosts = Puppetdb.client.query_nodes
      @unknown_hosts = @puppetdb_hosts - @foreman_hosts
    end

    def destroy
      Puppetdb.client.deactivate_node(@node)
      process_success :success_msg => _('Deactivated node %s in PuppetDB') % @node, :success_redirect => puppetdb_foreman_nodes_path
    rescue => e
      process_error(:redirect => puppetdb_foreman_nodes_path, :error_msg => _('Failed to deactivate node in PuppetDB: %s') % e.message)
    end

    private

    def find_node
      @node = params[:id]
    end
  end
end
