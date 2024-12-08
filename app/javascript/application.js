// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

window.addEventListener("click", e=>{
    if(e.target.closest("[data-url]")) location.href = e.target.closest("[data-url]").dataset.url;
})