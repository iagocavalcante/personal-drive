import templateComponent from './template'

const components = [
  templateComponent
]

class Init {
  constructor() {
    components.forEach((component) => {
      if (component.el) {
        let element = document.querySelector(component.el)
        element.innerHTML = component.template
      }
      component.afterBind()
    })

    if (process.env.NODE_ENV === 'production') {
      this.registerSW()
    }
  }

  registerSW() {
    if ('serviceWorker' in navigator) {
      navigator.serviceWorker.register('./service-worker.js')
    }
  }
}

new Init()