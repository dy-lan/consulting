require 'date'
require 'time'
require_relative 'connection'
require_relative 'orgs'

module Repos
  def self.active_repos
    active_repos = []
    active_since_date = Date.parse('September 1 2019')

    latest_update_per_repo.each do |repo_full_name, last_update|
      active_repos.push(repo_full_name) if last_update > active_since_date
    end

    active_repos
  end

  def self.latest_update_per_repo
    latest_update_per_repo = {}

    repos_per_org.each do |_org_name, repos|
      repos.each do |repo|
        latest_update_per_repo[repo.full_name] = repo.updated_at.to_date
      end
    end

    latest_update_per_repo
  end

  def self.repos_per_org
    repos_per_org = {}

    Orgs.org_names.each do |org_name|
      repos = []

      $client.org_repos(org_name).each do |repo|
        repos.push(repo)
      end

      repos_per_org[org_name] = repos
    end

    repos_per_org
  end

  def self.total_active_repos
    active_repos.size
  end

  def self.total_repos
    total_repos = 0

    total_repos_per_org.each do |_org_name, total_repos_per_org|
      total_repos += total_repos_per_org
    end

    total_repos
  end

  def self.total_repos_per_org
    total_repos_per_org = {}

    repos_per_org.each do |org_name, repos|
      total_repos_per_org[org_name] = repos.size
    end

    total_repos_per_org
  end
end
