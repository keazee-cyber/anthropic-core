#!/bin/bash
# === Anthropic Core v1.0.0 - Configuration shell personnalisée ===

# Variable globale pour le chemin du core
export ANTHROPIC_CORE="$HOME/.anthropic_core/anthropic_core.sh"

# Affiche la version du Core
version() {
  echo "Anthropic Core v1.0.0"
}

# Affiche l'aide et la liste des commandes
anthropic() {
  local command="$1"
  shift

  case "$command" in
    help)
      echo "=== Anthropic CLI — Aide ==="
      echo "Commandes disponibles :"
      echo "  status                → affiche le statut du Core"
      echo "  version               → affiche la version du Core"
      echo "  backup                → crée une sauvegarde horodatée du Core et du .bash_profile"
      echo "  restore-last-backup   → restaure la dernière sauvegarde"
      echo "  restore <nom>         → restaure une sauvegarde précise"
      echo "  list-backups          → affiche les sauvegardes disponibles"
      echo "  update [--force]      → met à jour le Core local"
      echo "  upgrade [--force]     → met à jour le Core depuis GitHub (avec SHA‑256)"
      echo "  publish               → publie le Core et le hash sur GitHub"
      echo "  help                  → affiche cette aide"
      return 0
      ;;
    version)
      version
      return 0
      ;;
    status)
      echo "=== Statut Anthropic Core ==="
      echo "Fichier core : $ANTHROPIC_CORE"
      echo "Version : $(version)"
      echo "Dossier de sauvegardes : $HOME/.anthropic_core/backups/"
      echo "Nombre de sauvegardes : $(ls -1 $HOME/.anthropic_core/backups/ | wc -l | xargs)"
      if [ -f "$HOME/.anthropic_core/SHA256SUM" ]; then
        echo "Hash SHA-256 actuel : $(cat $HOME/.anthropic_core/SHA256SUM)"
      else
        echo "Hash SHA-256 : non généré"
      fi
      return 0
      ;;
    backup)
      # Crée un dossier backups si il n'existe pas
      mkdir -p "$HOME/.anthropic_core/backups"
      local timestamp=$(date +%Y%m%d_%H%M%S)
      # Sauvegarde .bash_profile et le core
      cp "$HOME/.bash_profile" "$HOME/.anthropic_core/backups/bash_profile_$timestamp.bak"
      cp "$ANTHROPIC_CORE" "$HOME/.anthropic_core/backups/anthropic_core_$timestamp.bak"
      echo "💾 Sauvegardes créées :"
      echo "  - $HOME/.anthropic_core/backups/bash_profile_$timestamp.bak"
      echo "  - $HOME/.anthropic_core/backups/anthropic_core_$timestamp.bak"
      return 0
      ;;
    list-backups)
      echo "=== Sauvegardes disponibles ==="
      ls -1ht "$HOME/.anthropic_core/backups/"
      return 0
      ;;
    restore-last-backup)
      local last_backup=$(ls -1t "$HOME/.anthropic_core/backups/" | grep -E "(bash_profile|anthropic_core)" | head -n 2)
      echo "♻️  Restauration de la dernière sauvegarde..."
      for file in $last_backup; do
        if [[ $file == bash_profile_* ]]; then
          cp "$HOME/.anthropic_core/backups/$file" "$HOME/.bash_profile"
          echo "✅ .bash_profile restauré"
        elif [[ $file == anthropic_core_* ]]; then
          cp "$HOME/.anthropic_core/backups/$file" "$ANTHROPIC_CORE"
          echo "✅ anthropic_core.sh restauré"
        fi
      done
      source "$HOME/.bash_profile"
      echo "🎉 Restauration terminée, rechargement de la configuration effectué"
      return 0
      ;;
    restore)
      local name="$1"
      if [[ -z "$name" ]]; then
        echo "❌ Il faut préciser le nom de la sauvegarde"
        list-backups
        return 1
      fi
      echo "♻️  Restauration de la sauvegarde $name..."
      if [[ $name == bash_profile_* ]]; then
        cp "$HOME/.anthropic_core/backups/$name.bak" "$HOME/.bash_profile"
        echo "✅ .bash_profile restauré"
      elif [[ $name == anthropic_core_* ]]; then
        cp "$HOME/.anthropic_core/backups/$name.bak" "$ANTHROPIC_CORE"
        echo "✅ anthropic_core.sh restauré"
      else
        cp "$HOME/.anthropic_core/backups/bash_profile_$name.bak" "$HOME/.bash_profile" 2>/dev/null
        cp "$HOME/.anthropic_core/backups/anthropic_core_$name.bak" "$ANTHROPIC_CORE" 2>/dev/null
      fi
      source "$HOME/.bash_profile"
      echo "🎉 Restauration terminée, rechargement de la configuration effectué"
      return 0
      ;;
    update)
      backup >/dev/null
      local force="$1"
      echo "Mise à jour du Core en cours..."
      # Re-génération du hash interne
      local new_hash=$(shasum -a 256 "$ANTHROPIC_CORE" | awk '{print $1}')
      echo "$new_hash" > "$HOME/.anthropic_core/SHA256SUM"
      echo "✅ Mise à jour locale terminée, hash SHA-256 régénéré"
      return 0
      ;;
    upgrade)
      backup >/dev/null
      local force="$1"
      echo "⬇️  Téléchargement de la dernière version depuis GitHub..."
      cd "$HOME/.anthropic_core" || { echo "❌ Impossible d'accéder au dossier Core"; return 1; }

      # Télécharge la dernière version
      if curl -f -o anthropic_core.sh.tmp https://raw.githubusercontent.com/thierryteplier/anthropic-core/main/anthropic_core.sh; then
        # Vérifie le hash si il existe
        if [ -f "$HOME/.anthropic_core/SHA256SUM" ]; then
          local remote_hash=$(cat SHA256SUM)
          local tmp_hash=$(shasum -a 256 anthropic_core.sh.tmp | awk '{print $1}')
          if [ "$remote_hash" != "$tmp_hash" ] && [[ -z "$force" ]]; then
            echo "❌ Le hash SHA-256 ne correspond pas, annonce de sécurité annulée. Utilise --force pour forcer."
            rm anthropic_core.sh.tmp
            return 1
          fi
        fi
        # Remplace l'ancien fichier
        mv anthropic_core.sh.tmp "$ANTHROPIC_CORE"
        echo "✅ Mise à jour terminée, rechargement de la configuration..."
        source "$HOME/.bash_profile"
        echo "🎉 Mise à jour effectuée avec succès"
        return 0
      else
        echo "❌ Échec du téléchargement, vérifie ton URL GitHub"
        rm -f anthropic_core.sh.tmp
        return 1
      fi
      ;;
    publish)
      local message="$1"
      if [[ -z "$message" ]]; then
        message="Mise à jour Core v$(version | grep -Eo [0-9]+.[0-9]+.[0-9]+) du $(date +%Y-%m-%d)"
      fi

      # Sauvegarde automatique avant publication
      backup >/dev/null
      echo "🔒 Sauvegarde automatique effectuée avant publication"

      # Régénération du hash SHA-256
      local core_file="$HOME/.anthropic_core/anthropic_core.sh"
      local new_hash=$(shasum -a 256 "$core_file" | awk '{print $1}')
      echo "$new_hash" > "$HOME/.anthropic_core/SHA256SUM"
      echo "✅ Hash SHA-256 régénéré : $new_hash"

      # Push sur GitHub
      cd "$HOME/.anthropic_core" || { echo "❌ Impossible d'accéder au dossier Core"; return 1; }
      git add . >/dev/null
      git commit -m "$message" >/dev/null
      git push origin main >/dev/null

      echo "🎉 Publication terminée : $message"
      return 0
      ;;
    *)
      echo "❌ Commande inconnue. Tapez 'anthropic help' pour voir la liste des commandes."
      return 1
      ;;
  esac
}

# Complétion automatique pour les commandes anthropic
_anthropic_completions() {
  local cur=${COMP_WORDS[COMP_CWORD]}
  local commands="help version status backup restore-last-backup restore list-backups update upgrade publish"
  COMPREPLY=($(compgen -W "$commands" -- $cur))
}
complete -F _anthropic_completions anthropic
