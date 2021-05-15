require 'time'
require_relative 'connection'

module Jobs
  ACTIVE_SINCE_DATE = Time.parse('September 1 2019')

  def self.all_jobs
    $all_jobs = []

    $client.job.list_all.sort_by(&:downcase).each do |job_name|
      job_details = $client.job.list_details(job_name)

      if job_details.key?('jobs')
        job_details['jobs'].each do |hash|
          $all_jobs.push("#{job_name}/job/#{hash['name']}")
        end
      else
        $all_jobs.push(job_name)
      end
    end

    $all_jobs
  end

  def self.last_build_date
    $last_build_date = {}

    $all_jobs.each do |job_name|
      current_build_number = $client.job.get_current_build_number(job_name)

      if current_build_number.zero?
        build_date = 'This job has no builds'
      else
        epoch = $client.job.get_build_details(job_name, current_build_number)['timestamp']
        build_date = Time.strptime(epoch.to_s, '%Q').strftime('%Y-%m-%d')
      end

      $last_build_date[job_name] = build_date
    end

    $last_build_date
  end

  def self.active_jobs
    $active_jobs = []

    $last_build_date.each do |job_name, build_date|
      unless build_date == 'This job has no builds'
        $active_jobs.push(job_name) if Time.parse(build_date) > ACTIVE_SINCE_DATE
      end
    end

    $active_jobs
  end

  def self.total_jobs
    $all_jobs.size
  end

  def self.total_active_jobs
    $active_jobs.size
  end
end
