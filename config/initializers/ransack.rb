# disable ransack's search method, since we already use our own search methods
Ransack::Adapters::ActiveRecord::Base.class_eval('remove_method :search')

Ransack.configure do |c|
  c.custom_arrows = {
    up_arrow: '<i class="fa fa-sort-up"></i>',
    down_arrow: '<i class="fa fa-sort-down"></i>',
    default_arrow: '<i style="color: #a8a8a8;" class="fa fa-sort"></i>'
  }
end
