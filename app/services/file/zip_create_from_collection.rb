# Create a zipfile from existing elements in collection
# context: temp dir to create zipfile, will be created if not existant
# collection: hash with {unique_filename_in_zip => absolute_path_to_file_to_include}
# filename in zip must be unique, path to file must be absolute including filename
class ZipCreateFromCollection

  # initialize with invoice object to send an invoice
  def initialize(collection)
    @collection = collection
  end

  def perform
    # create unique tempfile
    tmp_file = Tempfile.new('tmp.zip')

    begin
      Zip::OutputStream.open(tmp_file) { |zos| }
      Zip::File.open(tmp_file.path, Zip::File::CREATE) do |zip|
        @collection.each do |filename, attachment|
          if !attachment.nil? && File.exists?(attachment)
            zip.add(filename, attachment)
          end
        end
      end

      zip_data = File.read(tmp_file.path)
      #send_data(zip_data, type: 'application/zip', disposition: 'attachment', filename: filename)
    ensure
      tmp_file.close
      tmp_file.unlink

    end
    return zip_data
  end




end
