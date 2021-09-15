<% if namespaced? -%>
require_dependency "<%= namespaced_file_path %>/application_controller"

<% end -%>
<% module_namespacing do -%>
class <%= controller_class_name %>Controller < ApplicationController
  before_action :set_<%= singular_table_name %>, only: %i(show edit update destroy)

  # GET <%= route_url %>
  def index
    # @<%= plural_table_name %> = <%= orm_class.all(class_name) %>
    # @<%= plural_table_name %> = <%= human_name %>.page(params[:page]).order('id ASC')
    @<%= plural_table_name %> = if params[:search]
      <%= human_name %>.where('name LIKE ?', "%#{params[:search]}%").page(params[:page]).order('name ASC')
    else
      <%= human_name %>.page(params[:page]).order('name ASC')
    end
  end

  # GET <%= route_url %>/1
  def show
  end

  # GET <%= route_url %>/new
  def new
    @<%= singular_table_name %> = <%= orm_class.build(class_name) %>
  end

  # GET <%= route_url %>/1/edit
  def edit
  end

  # POST <%= route_url %>
  def create
    @<%= singular_table_name %> = <%= orm_class.build(class_name, "#{singular_table_name}_params") %>
    if @<%= orm_instance.save %>
      redirect_to @<%= singular_table_name %>, notice: <%= "t(:creation_successful)" %>
    else
      render action: 'new'
    end
  end

  # PATCH/PUT <%= route_url %>/1
  def update
    if @<%= orm_instance.update("#{singular_table_name}_params") %>
      redirect_to @<%= singular_table_name %>, notice: <%= "t(:update_successful)" %>
    else
      render action: 'edit'
    end
  end

  # DELETE <%= route_url %>/1
  def destroy
    @<%= orm_instance.destroy %>
    redirect_to <%= index_helper %>_url, notice: <%= "t(:delete_successful)" %>
  end

  private

  def set_<%= singular_table_name %>
    @<%= singular_table_name %> = <%= orm_class.find(class_name, "params[:id]") %>
  end

  def <%= "#{singular_table_name}_params" %>
    <%- if attributes_names.empty? -%>
    params[<%= ":#{singular_table_name}" %>]
    <%- else -%>
    params.require(<%= ":#{singular_table_name}" %>).permit(<%= attributes_names.map { |name| ":#{name}" }.join(', ') %>)
    <%- end -%>
  end
end
<% end -%>
