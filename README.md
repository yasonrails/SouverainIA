# SouverainIA

Infrastructure IA souveraine pour l’industrie française

## Objectif stratégique

Créer et industrialiser une plateforme souveraine clé en main permettant aux entreprises françaises de déployer, fine-tuner et exploiter des modèles IA 100% en local, garantissant :

- La souveraineté des données
- La sécurité informatique
- L’autonomie industrielle
- Une mise à l’échelle rapide dans plusieurs secteurs stratégiques.

## Description du produit

SouverainIA est une solution complète comprenant :

### Infrastructure logicielle

- Plateforme d’orchestration de modèles IA.
- Pipeline automatisé de création/fine-tuning de modèles métier.
- API souveraine pour intégration dans les systèmes métiers.
- Interface dashboard pour gestion, monitoring et reporting.

### Sécurité

- Chiffrement bout-à-bout des données.
- Gestion des accès basée sur rôle.
- Conformité RGPD et certifications nécessaires.

## Cas d’usage

- Industrie 4.0 : maintenance prédictive, optimisation de production.
- Santé : analyse de données médicales internes.
- Cybersécurité : détection d’anomalies.
- Énergie : prédiction de consommation.

## Installation

1. `bundle install`
2. `rails db:create db:migrate`
3. `rails db:seed` (pour créer un compte demo)
4. `rails s`

## Utilisation

- Connectez-vous avec le compte demo : email `demo@souverainia.fr`, mot de passe `demo123`
- Créez des modèles IA dans /ai_models
- Configurez des pipelines dans /pipelines
- Utilisez l'API à /api/v1/

## Technologies

- Ruby on Rails
- PostgreSQL
- Active Storage
- Devise, Pundit
- Bootstrap

## Développement

Pour Phase 3, ce démonstrateur montre la plateforme de gestion. L'IA locale serait intégrée via des jobs Sidekiq appelant des scripts Python locaux.
