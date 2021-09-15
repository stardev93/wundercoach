class Pdftemplate < ActiveRecord::Base
  acts_as_tenant(:account)

  has_attached_file :bgfile, styles: { thumb: "500x500>" }, default_url: "/images/:style/missing.png"
  validates_attachment_content_type :bgfile, content_type: /\Aimage\/.*\z/

  has_attached_file :header, styles: { thumb: "290x100>" }, default_url: "/images/:style/missing.png"
  validates_attachment_content_type :header, content_type: /\Aimage\/.*\z/

  has_attached_file :footer, styles: { thumb: "290x100>" }, default_url: "/images/:style/missing.png"
  validates_attachment_content_type :footer, content_type: /\Aimage\/.*\z/

  def to_s
    "#{name}"
  end

  def pdf_options
    {
      margin: {
        top: "#{(top.nil? ? '30mm' : top)}",
        bottom: "#{(bottom.nil? ? '20mm' : bottom)}",
        left: "#{(left.nil? ? '20mm' : left)}",
        right: "#{(right.nil? ? '20mm' : right)}"
      }
    }
  end

  def background

  end
end
