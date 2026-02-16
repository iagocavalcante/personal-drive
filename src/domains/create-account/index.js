import { database } from './../../configuration/firebase'

export const authCreateEmail = function () {
  alert('Criação de conta')

  let email = prompt('Qual seu email', '')
  let password = prompt('Qual sua senha', '')

  auth.createUserWithEmailAndPassword(email, password)
    .then(function (data) {
      (data)
    })
    .catch(function (err) {
      console.log(err)
    })
}

export const authEmail = function () {
  alert('Autenticação')

  let email = prompt('Qua seu email:', '')
  let password = prompt('Qua sua senha:', '')

  auth.signInWithEmailAndPassword(email, password)
    .then(function (data) {
      console.log(data)
    })
    .catch(function (err) {
      console.log(err)
    })
}