Quiztube::Application.routes.draw do

  devise_for :users

  #LESSONS
  match "lessons/update_status" => "lessons#update_status"
  match "lessons/publish" => "lessons#publish"
  match "lessons/add" => "lessons#add"

  #QUESTIONS
  match "questions/save_question" => "questions#save_question", :as => :save_question_path
  match "compare_question" => "questions#compare_question"

  resources :answers
  resources :lessons
  resources :questions

  root :to => "static#home"
end
