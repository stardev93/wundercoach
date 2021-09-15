class PdftemplatesController < ApplicationController
  before_action :set_pdftemplate, only: %i(show edit update destroy removebgfile)

  # GET /pdftemplates
  def index
    # @pdftemplates = Pdftemplate.all
    # @pdftemplates = Pdf template.page(params[:page]).order('id ASC')
    @pdftemplates = if params[:search]
      Pdftemplate.where('name LIKE ?', "%#{params[:search]}%").page(params[:page]).order('name ASC')
    else
      Pdftemplate.page(params[:page]).order('name ASC')
    end
  end

  # GET /pdftemplates/1
  def show
  end

  # GET /pdftemplates/1
  def removebgfile
    @pdf_template.bgfile.destroy
    @pdf_template.save!
    redirect_to @pdf_template, notice: t(:background_file_removed_successfully)
  end

  # GET /pdftemplates/new
  def new
    @pdf_template = Pdftemplate.new
  end

  # GET /pdftemplates/1/edit
  def edit
  end

  # POST /pdftemplates
  def create
    @pdf_template = Pdftemplate.new(pdftemplate_params)
    if @pdf_template.save
      redirect_to @pdf_template, notice: t(:creation_successful)
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /pdftemplates/1
  def update
    if @pdf_template.update(pdftemplate_params)
      redirect_to @pdf_template, notice: t(:update_successful)
    else
      render action: 'edit'
    end
  end

  # DELETE /pdftemplates/1
  def destroy
    @pdf_template.destroy
    redirect_to pdftemplates_url, notice: t(:delete_successful)
  end

  private

  def set_pdftemplate
    @pdf_template = Pdftemplate.find(params[:id])
  end

  def pdftemplate_params
    params.require(:pdftemplate).permit(:name, :description, :body_code, :header_code, :footer_code, :settings, :css, :bgfile, :top, :bottom, :left, :right, :header, :footer)
  end
end
