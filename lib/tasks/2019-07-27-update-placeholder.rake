namespace :wc do
  desc "Update placeholders required for inserting variable value into texts"
  task :update_placeholders => :environment do

    i = 1
    Placeholder.by_name.each do |placeholder|
      puts placeholder
      placeholder.objecttype, placeholder.display_name = placeholder.name[1..-2].split(".")
      placeholder.sortorder = i
      placeholder.save!
      i = i + 10
    end


  end
end
