# frozen_string_literal: true

class Web::Admin::ResumesController < Web::Admin::ApplicationController
  def index
    query = { s: 'created_at desc' }.merge(params.permit![:q] || {})
    @search = Resume.ransack(query)
    @resumes = @search.result(distinct: true).includes(:user).page(params[:page])
  end

  # TODO: сделать возможным просматривать админам архивные и неопубликованные резюме
  def show; end

  def edit
    @resume = Resume.find params[:id]
    @resume_educations = @resume.educations.web
    @resume_works = @resume.works.web
  end

  def update
    resume = Resume.find params[:id]
    @resume = resume.becomes(Web::Admin::ResumeForm)
    if @resume.update(params[:resume])
      f(:success)
      redirect_to admin_resumes_path
    else
      f(:error)
      render :edit, status: :unprocessable_entity
    end
  end

  def archive
    resume = Resume.find(params[:id])
    resume.archive!
    f(:success)
    redirect_to admin_resumes_path(page: params[:page])
  end

  def restore
    resume = Resume.find(params[:id])
    resume.restore!
    f(:success)
    redirect_to admin_resumes_path(page: params[:page])
  end
end
