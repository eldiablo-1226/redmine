// rails-ujs asks for confirmation synchronously, so a <dialog> cannot answer it
// directly. The first call always declines, opens the dialog, and replays the
// original interaction once the person accepts.

const TEMPLATE_ID = 'nx-confirm-template'

function ask(message) {
  const template = document.getElementById(TEMPLATE_ID)
  if (!template) { return Promise.resolve(window.confirm(message)) }

  const dialog = template.content.firstElementChild.cloneNode(true)
  dialog.querySelector('.nx-confirm-message').textContent = message
  document.body.appendChild(dialog)

  return new Promise(function (resolve) {
    function close(accepted) {
      dialog.close()
      dialog.remove()
      resolve(accepted)
    }
    dialog.querySelector('.nx-confirm-accept').addEventListener('click', function () { close(true) })
    dialog.querySelector('.nx-confirm-cancel').addEventListener('click', function () { close(false) })
    // Escape and the backdrop both mean "no".
    dialog.addEventListener('cancel', function (event) { event.preventDefault(); close(false) })
    dialog.showModal()
    dialog.querySelector('.nx-confirm-cancel').focus()
  })
}

function replay(element) {
  // A context menu closes as soon as it is clicked, so the element that asked
  // for confirmation may no longer be in the document to click again.
  if (element.isConnected) {
    element.click()
  } else if (element.getAttribute('data-method')) {
    window.Rails.handleMethod.call(element, new MouseEvent('click'))
  }
}

function install() {
  const rails = window.Rails
  if (!rails) { return }

  rails.confirm = function (message, element) {
    if (element.dataset.nxConfirmed === 'true') {
      delete element.dataset.nxConfirmed
      return true
    }
    ask(message).then(function (accepted) {
      if (!accepted) { return }
      element.dataset.nxConfirmed = 'true'
      replay(element)
    })
    return false
  }
}

if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', install)
} else {
  install()
}
