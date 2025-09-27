import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["content"]

  connect() {
    this.expanded = false
  }

  toggle() {
    this.expanded = !this.expanded
    this.contentTarget.classList.toggle("show")
    this.element.classList.toggle("expanded")
  }

  submit() {
    // Récupérer le formulaire
    const form = this.element.querySelector("#advanced-filters")
    const formData = new FormData(form)

    // Ajouter l'indicateur de chargement
    const resultsContainer = document.querySelector("#filtered-results")
    resultsContainer.classList.add("loading")

    // Envoyer la requête AJAX
    fetch(form.action + "?" + new URLSearchParams(formData), {
      headers: {
        "Accept": "application/json",
        "X-Requested-With": "XMLHttpRequest"
      }
    })
    .then(response => response.json())
    .then(data => {
      resultsContainer.innerHTML = data.html
      this.showFilterNotification(data.count)
    })
    .finally(() => {
      resultsContainer.classList.remove("loading")
    })
  }

  showFilterNotification(count) {
    const event = new CustomEvent("notification", {
      detail: {
        type: "info",
        title: "Filtres appliqués",
        message: `${count} résultats trouvés`
      }
    })
    window.dispatchEvent(event)
  }
}