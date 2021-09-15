binary_path = if %w(staging production).include? ENV["RAILS_ENV"]
                "/usr/bin/wkhtmltopdf"
              else
                "/usr/local/bin/wkhtmltopdf"
              end
WickedPdf.config = {
  wkhtmltopdf: '/usr/bin/wkhtmltopdf',
  layout: "pdf.html"
}
