say "  - Setting up error pages"

template 'template_files/app/controllers/errors_controller.rb', 'app/controllers/errors_controller.rb'

template 'template_files/app/views/errors/not_found.html.erb', 'app/views/errors/not_found.html.erb'
template 'template_files/app/views/errors/unprocessable_entity.html.erb', 'app/views/errors/unprocessable_entity.html.erb'
# template 'template_files/app/views/errors/too_many_requests.html.erb', 'app/views/errors/too_many_requests.html.erb'
template 'template_files/app/views/errors/internal_server_error.html.erb', 'app/views/errors/internal_server_error.html.erb'

routes = <<-RUBY

  scope via: :all do
    get '/404', to: 'errors#not_found'
    get '/422', to: 'errors#unprocessable_entity'
    get '/429', to: 'errors#too_many_requests'
    get '/500', to: 'errors#internal_server_error'
  end
RUBY

insert_into_file('config/routes.rb', routes, before: /^end/)

initializer "error_pages.rb", <<-RUBY
  Rails.application.config.exceptions_app = Rails.application.routes
RUBY

remove_file 'public/400.html'
remove_file 'public/406-unsupported-browser.html'
remove_file 'public/404.html'
remove_file 'public/422.html'
remove_file 'public/500.html'
