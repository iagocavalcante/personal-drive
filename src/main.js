require('./style.scss')
console.log('Hey Ho')

class Init {
  constructor () {
    let partial = require('./teste.html')
    let app = document.getElementById('app')
    app.innerHTML = partial
  }
}

new Init()