require 'time'
require_relative 'connection'

module Jobs
  ACTIVE_SINCE_DATE = Time.parse('September 1 2019')
  ALL_JOBS = []
  LAST_BUILD_DATE = {}
  ACTIVE_JOBS = []

  def self.all_jobs
    $client.job.list_all.sort_by(&:downcase).each do |job_name|
      job_details = $client.job.list_details(job_name)

      if job_details.key?('jobs')
        job_details['jobs'].each do |hash|
          ALL_JOBS.push("#{job_name}/job/#{hash['name']}")
        end
      else
        ALL_JOBS.push(job_name)
      end
    end
  end

  def self.last_build_date
    ALL_JOBS.each do |job_name|
      current_build_number = $client.job.get_current_build_number(job_name)

      if current_build_number.zero?
        build_date = 'This job has no builds'
      else
        epoch = $client.job.get_build_details(job_name, current_build_number)['timestamp']
        build_date = Time.strptime(epoch.to_s, '%Q').strftime('%Y-%m-%d')
      end

      LAST_BUILD_DATE[job_name] = build_date
    end

    LAST_BUILD_DATE
  end

  def self.active_jobs
    LAST_BUILD_DATE.each do |job_name, build_date|
      unless build_date == 'This job has no builds'
        ACTIVE_JOBS.push(job_name) if Time.parse(build_date) > ACTIVE_SINCE_DATE
      end
    end

    ACTIVE_JOBS
  end

  def self.total_jobs
    ALL_JOBS.size
  end

  def self.total_active_jobs
    ACTIVE_JOBS.size
  end
end
