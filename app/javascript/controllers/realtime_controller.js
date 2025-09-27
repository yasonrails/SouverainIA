// Gestion des notifications et mises à jour en temps réel
import consumer from "./consumer"

document.addEventListener('turbo:load', () => {
  // Initialisation des notifications
  initNotifications()
  
  // Initialisation des filtres
  initFilters()
  
  // Initialisation des gestures mobiles
  initMobileGestures()
})

// Gestion des notifications temps réel
const initNotifications = () => {
  const subscription = consumer.subscriptions.create("ModelStatusChannel", {
    connected() {
      console.log("Connected to ModelStatusChannel")
    },

    disconnected() {
      console.log("Disconnected from ModelStatusChannel")
    },

    received(data) {
      // Mise à jour des statuts et notifications
      updateModelStatus(data)
      showNotification(data)
    }
  })
}

// Mise à jour du statut des modèles en temps réel
const updateModelStatus = (data) => {
  const modelRow = document.querySelector(`#model-${data.model_id}`)
  if (modelRow) {
    const statusBadge = modelRow.querySelector('.status-badge')
    const progressBar = modelRow.querySelector('.progress-bar')
    
    if (statusBadge) {
      statusBadge.innerHTML = `
        <i class="fas fa-circle me-1" style="font-size: 8px"></i>
        ${data.status}
      `
      statusBadge.className = `badge badge-modern badge-${data.status_class}`
    }
    
    if (progressBar && data.progress) {
      progressBar.style.width = `${data.progress}%`
      progressBar.setAttribute('aria-valuenow', data.progress)
    }
  }
}

// Affichage des notifications
const showNotification = (data) => {
  const notification = document.createElement('div')
  notification.className = 'notification-toast'
  notification.innerHTML = `
    <div class="modern-card notification-content ${data.type || 'info'}">
      <div class="d-flex align-items-center">
        <i class="fas ${getNotificationIcon(data.type)} me-3"></i>
        <div>
          <h6 class="mb-0">${data.title}</h6>
          <p class="mb-0 small">${data.message}</p>
        </div>
      </div>
    </div>
  `
  
  document.body.appendChild(notification)
  
  // Animation d'entrée
  setTimeout(() => {
    notification.classList.add('show')
  }, 100)
  
  // Suppression automatique
  setTimeout(() => {
    notification.classList.remove('show')
    setTimeout(() => notification.remove(), 300)
  }, 5000)
}

// Icônes pour les notifications
const getNotificationIcon = (type) => {
  switch(type) {
    case 'success': return 'fa-check-circle'
    case 'error': return 'fa-exclamation-circle'
    case 'warning': return 'fa-exclamation-triangle'
    default: return 'fa-info-circle'
  }
}

// Gestion des filtres avancés
const initFilters = () => {
  const filterForm = document.querySelector('#advanced-filters')
  if (filterForm) {
    filterForm.addEventListener('submit', (e) => {
      e.preventDefault()
      const formData = new FormData(filterForm)
      
      fetch(filterForm.action, {
        method: 'GET',
        headers: {
          'Accept': 'application/json',
          'X-Requested-With': 'XMLHttpRequest'
        },
        body: formData
      })
      .then(response => response.json())
      .then(data => {
        updateResults(data)
      })
    })
  }
}

// Mise à jour des résultats filtrés
const updateResults = (data) => {
  const resultsContainer = document.querySelector('#filtered-results')
  if (resultsContainer) {
    resultsContainer.innerHTML = data.html
  }
}

// Gestion des gestes tactiles
const initMobileGestures = () => {
  const cards = document.querySelectorAll('.modern-card')
  
  cards.forEach(card => {
    let touchStartX = 0
    let touchEndX = 0
    
    card.addEventListener('touchstart', (e) => {
      touchStartX = e.changedTouches[0].screenX
    })
    
    card.addEventListener('touchend', (e) => {
      touchEndX = e.changedTouches[0].screenX
      handleSwipe(card, touchStartX, touchEndX)
    })
  })
}

// Gestion des swipes sur mobile
const handleSwipe = (element, startX, endX) => {
  const threshold = 100
  const diff = endX - startX
  
  if (Math.abs(diff) > threshold) {
    if (diff > 0) {
      // Swipe droite
      showQuickActions(element, 'right')
    } else {
      // Swipe gauche
      showQuickActions(element, 'left')
    }
  }
}

// Affichage des actions rapides sur mobile
const showQuickActions = (element, direction) => {
  const actions = element.querySelector('.quick-actions')
  if (actions) {
    if (direction === 'left') {
      actions.classList.add('show')
    } else {
      actions.classList.remove('show')
    }
  }
}