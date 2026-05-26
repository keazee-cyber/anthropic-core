#!/bin/bash
echo "🧪 Test automatisé du Anthropic Core CLI"
echo "========================================"

# Test 1 : Structure du dossier
echo "1/ Test de la structure du dossier core..."
if [[ -d "$HOME/.anthropic_core" && -f "$HOME/.anthropic_core/anthropic_core.sh" ]]; then
  echo "✅ Structure OK"
else
  echo "🔴 Structure KO"
  exit 1
fi

# Test 2 : Commande anthropic disponible
echo "2/ Test de la commande anthropic..."
if type anthropic >/dev/null 2>&1; then
  echo "✅ Commande anthropic disponible"
else
  echo "🔴 Commande anthropic introuvable"
  exit 1
fi

# Test 3 : Création de sauvegarde
echo "3/ Test de sauvegarde..."
anthropic backup >/dev/null
if [[ $(ls -1 ~/.anthropic_core/backups/ | wc -l) -gt 0 ]]; then
  echo "✅ Sauvegarde créée avec succès"
else
  echo "🔴 Échec de la sauvegarde"
fi

# Test 4 : Liste des sauvegardes
echo "4/ Test list-backups..."
if anthropic list-backups | grep -q "bash_profile"; then
  echo "✅ Liste des sauvegardes OK"
else
  echo "🔴 Liste des sauvegardes KO"
fi

# Test 5 : Vérification du hash
echo "5/ Vérification du SHA-256..."
if [[ -f "$HOME/.anthropic_core/SHA256SUM" && $(wc -l < "$HOME/.anthropic_core/SHA256SUM") -eq 1 ]]; then
  echo "✅ Hash SHA-256 OK"
else
  echo "🔴 Hash SHA-256 KO"
fi

echo ""
echo "🎉 Tous les tests sont terminés ! Ton Core est prêt à l'emploi."
