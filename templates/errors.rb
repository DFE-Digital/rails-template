template 'app/controllers/errors_controller.rb'

template 'app/views/errors/internal_server_error.html.erb'
template 'app/views/errors/not_found.html.erb'
template 'app/views/errors/unprocessable_entity.html.erb'

routes = <<-RUBY

  scope via: :all do
    get '/404', to: 'errors#not_found'
    get '/422', to: 'errors#unprocessable_entity'
    get '/429', to: 'errors#too_many_requests'
    get '/500', to: 'errors#internal_server_error'
  end
RUBY

insert_into_file('config/routes.rb', routes, before: 'end')

insert_into_file(
  'config/application.rb',
  "\nconfig.exceptions_app = routes\n".indent(4),
  before: "  end\nend"
)

remove_file 'public/404.html'
remove_file 'public/422.html'
remove_file 'public/500.html'
