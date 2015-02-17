class JobsController < ApplicationController

  before_filter :signed_in_user

  def index

    @user_id = params[:user_id] ? params[:user_id].to_i : current_user.id

    if @user_id == -1

      now = Time.now

      @active_jobs =  Job.where("pc >= 0")
      @urgent_jobs =  Job.where("pc = -1 AND latest_start_time < ?", now)
      @pending_jobs = Job.where("pc = -1 AND desired_start_time < ? AND ? <= latest_start_time", now, now)
      @later_jobs  =  Job.where("pc = -1 AND ? <= desired_start_time", now)

    else

      @user = User.find(@user_id)

      now = Time.now

      @active_jobs =  Job.where("pc >= 0")
      @urgent_jobs =  Job.where("pc = -1 AND latest_start_time < ?", now)
      @pending_jobs = Job.where("pc = -1 AND desired_start_time < ? AND ? <= latest_start_time", now, now)
      @later_jobs  =  Job.where("pc = -1 AND ? <= desired_start_time", now)

      [@active_jobs, @urgent_jobs, @pending_jobs, @later_jobs].each do |jl|
        jl.select! { |j| j.user_id.to_i == @user.id || (@user.member? j.group_id) || j.submitted_by == current_user.id }
      end

    end

  end

  def show

    begin
      @job = Job.find(params[:id])
    rescue
      redirect_to logs_path
      return
    end

    if /\.rb$/ =~ @job.path
      return redirect_to krill_log_path(job: @job.id)
    end

    if @job.group_id
      @group = Group.find_by_id(@job.group_id)
    else
      @group = nil
    end

    if @job.user_id.to_i >= 0
      @user =  User.find_by_id(@job.user_id)
    else
      @user = nil
    end

    if @job.submitted_by
      @submitter = User.find_by_id(@job.submitted_by)
    else
      @submitter = nil
    end

    @status = @job.status

  end

  def destroy
    Job.find(params[:id]).destroy
    flash[:success] = "Job #{params[:id]} has been cancelled."
    redirect_to jobs_url
  end

  def summary

    if params[:sha]

      @jobs = Job.where( 'path = ? AND sha = ?', params[:path], params[:sha] )

      if /local_file/ =~ params[:sha]
        blob = Blob.get params[:sha], params[:path]
        @content = blob.xml.force_encoding('UTF-8')
      else
        begin
          @content = Repo::contents params[:path], params[:sha] 
        rescue Exception => e
          @content = "Could not find '#{params[:path]}' with sha '#{params[:sha]}'.<br />The repository information is probably not part of the path because the path was stored to the<br />database in the octokit era.".html_safe
        end
      end

    elsif params[:path]

      @infos = {}

      Job.where(path: params[:path]).reverse.each do |j|
        if ! @infos[j.sha]
          @infos[j.sha] = {
            num: 1,
            first: j.created_at,
            last: j.created_at
          }
        else
          @infos[j.sha] = {
            num: @infos[j.sha][:num] + 1,
            last: @infos[j.sha][:last],      
            first: j.created_at
          }
        end
      end

      @infos.each do |k,v|
        @infos[k][:posts] = PostAssociation.where(sha: k).count
      end

      # @shas = Job.where('path = ?', params[:path]).uniq.pluck(:sha) #.reject { |s| /local/.match s }
      # @infos = @shas.collect do |s|
      #   jobs = Job.where( 'path = ? AND sha = ?', params[:path], s ).sort { 
      #     |j,k| j.created_at <=> k.created_at 
      #   }
      #   { 
      #     sha: s,
      #     num: jobs.length,
      #     first: jobs.first.created_at,
      #     last: jobs.last.created_at
      #   }
      # end

    else

      @paths = (Job.uniq.pluck(:path).reject { |p| !p || /\.pdl$/ =~ p || /\.pl$/ =~ p }).sort

    end

  end

  def upload
    redirect_to Upload.find(params[:id]).url
  end

end
