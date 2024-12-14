// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

window.addEventListener("click", e => {
    const data_url_element = e.target.closest("[data-url]");
    const button_element = e.target.closest("button, a");
    if (!!data_url_element && (!button_element || button_element.contains(data_url_element))){
        const turbo_frame_id = e.target.closest("turbo-frame")?.id;
        if(turbo_frame_id && data_url_element.dataset.frame!=="false"){
            navigateTo(data_url_element.dataset.url, {frame: turbo_frame_id})
        }else{
            navigateTo(data_url_element.dataset.url)
        }
    }
})

function navigateTo(url, options = {}) {
    if (window.Turbo) {
        if (options.frame) {
            const frame = document.querySelector(`turbo-frame[id="${options.frame}"]`);
            if (frame) {
                frame.src = url;
                return;
            }
        }
        Turbo.visit(url);
    } else {
        location.href = url;
    }
}
