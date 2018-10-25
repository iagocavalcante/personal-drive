import { app } from './../../configuration/firebase'
import { authCreateEmail, authEmail } from './../create-account'
import { UserClass } from './user/user'
import fileListComponent from './../../domains/files-list/'

let template = document.createElement('template')
template.innerHTML = require('./template/index.html')
template = template.content.childNodes

document.querySelector('body').appendChild(template[0])

export default {
  el: null,
  template: null,
  afterBind () {
    app.auth().onAuthStateChanged(function (user) {
      if (user) {
        const userInstance = new UserClass
        userInstance.user = user

        let element = document.querySelector(fileListComponent.el)
        element.innerHTML = fileListComponent.template
        fileListComponent.afterBind()

        const auth = document.getElementById('auth')
        auth.className = 'modal'

        const sha1 = require('js-sha1')

        let ref = app.database().ref('/sharer/' + sha1(user.email))
        ref.set(user.uid)
      } else {
        const auth = document.getElementById('auth')
        auth.className = 'modal open'

        document.querySelector('#auth-email').addEventListener('click', function(e) {
          e.preventDefault()
          authEmail()
        })

        document.querySelector('#auth-create-email').addEventListener('click', function(e) {
          e.preventDefault()
          authCreateEmail()
        })
      }
    })
  }
}