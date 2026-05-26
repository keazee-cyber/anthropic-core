#!/usr/bin/env bash
# ==========================================================
# Anthropic Core CLI — version 2.1.0 (macOS/Linux compatible)
# ==========================================================

CORE_VERSION="2.1.0"
CORE_NAME="Anthropic Core CLI"
CORE_FILE="$HOME/.anthropic_core/anthropic_core.sh"
BACKUP_DIR="$HOME/.anthropic_core/backups"
BASH_PROFILE="$HOME/.bash_profile"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# --- Fonction : affichage d’en-tête ---
header() {
  echo "=== $CORE_NAME (v$CORE_VERSION) ==="
}

# --- Fonction : sauvegarde du .bash_profile ---
backup_core() {
  header
  echo "💾 Sauvegarde du fichier ~/.bash_profile"

  mkdir -p "$BACKUP_DIR"
  local BACKUP_FILE="$BACKUP_DIR/bash_profile_backup_$TIMESTAMP"
  cp "$BASH_PROFILE" "$BACKUP_FILE"
  echo "✅ Sauvegarde créée : $BACKUP_FILE"
}

# --- Fonction : restauration du .bash_profile ---
restore_bash_profile() {
  header
  echo "🩺 Restauration du fichier .bash_profile depuis la sauvegarde..."
  local LATEST_BACKUP
  LATEST_BACKUP=$(ls -t "$BACKUP_DIR"/bash_profile_backup_* 2>/dev/null | head -n 1)

  if [ -z "$LATEST_BACKUP" ]; then
    echo "❌ Aucune sauvegarde trouvée."
    return 1
  fi

  echo "Dernière sauvegarde trouvée : $LATEST_BACKUP"
  echo -n "Souhaitez-vous vraiment restaurer cette sauvegarde ? [o/N] "
  read -r confirmation

  case "$confirmation" in
    [oO]|[oO][uU][iI])
      cp "$LATEST_BACKUP" "$BASH_PROFILE"
      echo "✅ Fichier .bash_profile restauré avec succès."
      ;;
    *)
      echo "❎ Opération annulée."
      ;;
  esac
}

# --- Fonction : lister les sauvegardes (compatible macOS/Linux) ---
list_backups() {
  header
  echo "📂 Liste des sauvegardes dans $BACKUP_DIR :"
  if ls --version >/dev/null 2>&1; then
    ls -lh --time-style=long-iso "$BACKUP_DIR"
  else
    ls -lhT "$BACKUP_DIR"
  fi
}

# --- Fonction : mise à jour locale ---
update_core() {
  header
  echo "🔄 Mise à jour locale du Core..."
  echo "✅ Core local mis à jour avec succès (simulation)."
}

# --- Fonction : mise à jour depuis GitHub avec vérification SHA-256 ---
upgrade_core() {
  header
  echo "⬆️  Mise à jour du Core depuis GitHub..."
  echo -n "Souhaitez-vous vraiment télécharger et remplacer le Core depuis GitHub ? [o/N] "
  read -r confirmation

  case "$confirmation" in
    [oO]|[oO][uU][iI])
      TMP_DIR=$(mktemp -d)
      NEW_SCRIPT_URL="https://raw.githubusercontent.com/AnthropicCore/anthropic-core/main/anthropic_core.sh"
      SHA_URL="https://raw.githubusercontent.com/AnthropicCore/anthropic-core/main/anthropic_core.sh.sha256"

      echo "⏳ Téléchargement du script..."
      curl -fsSL "$NEW_SCRIPT_URL" -o "$TMP_DIR/new_core.sh" || { echo "❌ Échec du téléchargement."; return 1; }

      echo "⏳ Téléchargement du hash SHA‑256..."
      curl -fsSL "$SHA_URL" -o "$TMP_DIR/new_core.sh.sha256" || { echo "❌ Échec du téléchargement du hash."; return 1; }

      echo "🔐 Vérification de l’intégrité..."
      cd "$TMP_DIR" || return 1
      if shasum -a 256 -c new_core.sh.sha256 >/dev/null 2>&1; then
        echo "✅ Vérification SHA‑256 réussie."
        cp "$CORE_FILE" "$BACKUP_DIR/core_backup_$TIMESTAMP.sh"
        cp "$TMP_DIR/new_core.sh" "$CORE_FILE"
        chmod +x "$CORE_FILE"
        echo "✅ Core mis à jour depuis GitHub avec succès."
      else
        echo "❌ Vérification SHA‑256 échouée — mise à jour annulée."
        return 1
      fi
      ;;
    *)
      echo "❎ Opération annulée."
      ;;
  esac
}

# --- Fonction : affichage de la version ---
show_version() {
  header
  echo "📦 Fichier : $CORE_FILE"
  echo "📅 Dernière modification : $(date -r "$CORE_FILE" '+%d %b %Y %H:%M:%S')"
  echo "👤 Utilisateur : $(whoami)"
  echo "💻 Système : $(uname -srm)"
  echo "✅ Core opérationnel."
}

# --- Fonction : affichage de l’aide ---
show_help() {
  header
  echo
  echo "Commandes disponibles :"
  echo "  backup         → Sauvegarde le fichier .bash_profile"
  echo "  restore        → Restaure la dernière sauvegarde"
  echo "  list-backups   → Liste les sauvegardes disponibles"
  echo "  update         → Met à jour le Core local"
  echo "  upgrade        → Met à jour le Core depuis GitHub (avec vérification SHA‑256)"
  echo "  version        → Affiche la version et les infos système"
  echo
  echo "Exemple : anthropic backup --force"
}

# --- Dispatcher principal ---
case "$1" in
  backup) backup_core ;;
  restore) restore_bash_profile ;;
  list-backups) list_backups ;;
  update) update_core ;;
  upgrade) upgrade_core ;;
  version) show_version ;;
  *) show_help ;;
esac
