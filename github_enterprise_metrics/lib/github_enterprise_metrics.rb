require 'axlsx'
require_relative 'orgs'
require_relative 'repos'

active_orgs = Orgs.active_orgs
active_repos = Repos.active_repos
latest_update_per_repo = Repos.latest_update_per_repo
total_active_orgs = Orgs.total_active_orgs
total_active_repos = Repos.total_active_repos
total_orgs = Orgs.total_orgs
total_repos = Repos.total_repos
total_repos_per_org = Repos.total_repos_per_org

p = Axlsx::Package.new
wb = p.workbook

wb.add_worksheet(name: 'Totals') do |sheet|
  sheet.add_row ['Total Orgs', 'Total Repos', 'Total Active Orgs', 'Total Active Repos']
  sheet.add_row [total_orgs, total_repos, total_active_orgs, total_active_repos]
end

wb.add_worksheet(name: 'Active Orgs') do |sheet|
  sheet.add_row ['Org Name']
  active_orgs.each { |org_name| sheet.add_row [org_name] }
  sheet.auto_filter = 'A1:A1'
end

wb.add_worksheet(name: 'Active Repos') do |sheet|
  sheet.add_row ['Full Repo Name']
  active_repos.each { |repo_full_name| sheet.add_row [repo_full_name] }
  sheet.auto_filter = 'A1:A1'
end

wb.add_worksheet(name: 'Repos Per Org') do |sheet|
  sheet.add_row ['Org Name', 'Repo Count']
  total_repos_per_org.each do |org_name, repo_count|
    sheet.add_row [org_name, repo_count]
  end
  sheet.auto_filter = 'A1:B1'
end

wb.add_worksheet(name: 'Repo Activity') do |sheet|
  sheet.add_row ['Full Repo Name', 'Last Updated']
  latest_update_per_repo.each do |repo_full_name, last_update|
    sheet.add_row [repo_full_name, last_update]
  end
  sheet.auto_filter = 'A1:B1'
end

p.serialize('../reports/GitHub_Enterprise_Metrics.xlsx')
