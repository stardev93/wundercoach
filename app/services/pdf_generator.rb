# generates PDF using WickedPDF
class PdfGenerator
  # if no path is given, you cannot use create_pdf, since it creates a file at
  # the given path, but you can use rendered_pdf to return the pdf as a data stream
  def initialize(html_options, pdf_options, path = nil)
    @html_options = html_options
    @pdf_options = pdf_options
    @controller = ActionController::Base.new
    @controller.extend(ApplicationHelper)
    @controller.extend(Rails.application.routes.url_helpers)
    @path = path
  end

  def footer_html_options=(options)
    @pdf_options.merge! footer: {
      content: @controller.render_to_string(*options)
    }
  end

  def header_html_options=(options)
    @pdf_options.merge! header: {
      content: @controller.render_to_string(*options)
    }
  end

  # streams pdf into a file
  def create_pdf
    File.open(@path, 'wb') do |file|
      file << rendered_pdf
    end
  end

  # returns raw pdf stream without touching the file system
  def rendered_pdf
    WickedPdf.new.pdf_from_string(rendered_view, @pdf_options)
  end

  private

  def rendered_view
    @controller.render_to_string(*@html_options)
  end
end
