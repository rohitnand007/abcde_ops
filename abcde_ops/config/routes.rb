Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to: "home#index"

  scope '/api' do
    scope '/v1' do
      scope '/content_requests' do
        get 'get_not_uploaded_books_list' => "api/v1/content_requests#get_not_uploaded_books_list"
      end
    end
  end
end
