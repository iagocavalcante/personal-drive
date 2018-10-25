import file from './../file-uploader'
import folder from './../folder-uploader'
import photo from './../photo-uploader'
import audio from './../audio-recorder'
import note from './../note-uploader'

export default {
  el: '#footer',
  template: require('./index.html'),
  afterBind() {
    let btnCollection = document.querySelectorAll('#footer a')

    btnCollection.forEach((btn) => {
      btn.addEventListener('click', (e) => {
        e.preventDefault()
        let element = e.target

        if (element.tagName == 'I') {
          element = e.target.parentElement
        }

        if (element.tagName == 'A') {
          switch (element.dataset.uploadType) {
            case 'file':
              file()
              break
            case 'folder':
              folder()
              break
            case 'photo':
              photo()
              break
            case 'audio':
              audio()
              break
            case 'note':
              note()
              break
          }
        }
      })
    })
  }
}