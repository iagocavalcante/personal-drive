import { app } from './../../../configuration/firebase'
import getPath from './path'
import { UserClass } from './../../auth/user/user'

export default function (file, name) {
    const path = getPath()
    const storageRef = app.storage().ref()

    const userInstance = new UserClass

    const fileRef = storageRef.child('files/' + userInstance.user.uid + path + name)
    fileRef.put(file).then((snapshot) => {
      
      const folderRef = app.database().ref('files/' + userInstance.user.uid + path)
      storageRef.child('files/' + userInstance.user.uid + path + name).getDownloadURL()
        .then( url => {
          folderRef.push({
            type: 'file',
            title: name,
            url: url,
            size: snapshot.totalBytes
          })
        })

      const totalBytes = snapshot.totalBytes

      const userRef = app.database().ref('/users/' + userInstance.user.uid + '/usage')

      userRef.once('value', (snapshot) => {
        const size = snapshot.val() || 0
        userRef.set(totalBytes + size)
      }, err => console.log(err))
    })
}
