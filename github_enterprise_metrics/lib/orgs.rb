require_relative 'connection'
require_relative 'repos'

module Orgs
  def self.active_orgs
    active_orgs = []

    Repos.active_repos.each do |repo_full_name, _active|
      active_orgs.push(repo_full_name.split('/').first)
    end

    active_orgs.uniq
  end

  def self.org_names
    org_names = []

    $client.all_orgs.each do |org|
      org_names.push(org.login)
    end

    org_names.sort_by(&:downcase)
  end

  def self.total_active_orgs
    active_orgs.size
  end

  def self.total_orgs
    org_names.size
  end
end
