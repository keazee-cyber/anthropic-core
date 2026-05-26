#!/bin/bash
# ==========================================================
# Anthropic Core CLI – v2.1.0
# Gestion de l’environnement de développement Claude
# Auteur : Thierry Teplier (keazee-cyber)
# ==========================================================

CORE_VERSION="2.1.0"
CORE_DIR="$HOME/.anthropic_core"
BACKUP_DIR="$CORE_DIR/backups"
BASH_PROFILE="$HOME/.bash_profile"

# URLs GitHub pour la mise à jour
REMOTE_SCRIPT_URL="https://raw.githubusercontent.com/keazee-cyber/anthropic-core/main/anthropic_core.sh"
REMOTE_HASH_URL="https://raw.githubusercontent.com/keazee-cyber/anthropic-core/main/anthropic_core.sh.sha256"

# ==========================================================
# Fonctions utilitaires
# ==========================================================

log() { echo -e "$1"; }

ensure_dirs() {
  mkdir -p "$BACKUP_DIR"
}

# ==========================================================
# Sauvegarde et restauration
# ==========================================================

backup_profile() {
  ensure_dirs
  local timestamp
  timestamp=$(date +"%Y%m%d_%H%M%S")
  local backup_file="$BACKUP_DIR/bash_profile_backup_$timestamp"
  cp "$BASH_PROFILE" "$backup_file"
  log "✅ Sauvegarde créée : $backup_file"
}

restore_last_backup() {
  local last_backup
  last_backup=$(ls -t "$BACKUP_DIR"/bash_profile_backup_* 2>/dev/null | head -n 1)
  if [ -z "$last_backup" ]; then
    log "❌ Aucune sauvegarde trouvée."
  else
    cp "$last_backup" "$BASH_PROFILE"
    log "✅ Restauration effectuée depuis : $last_backup"
  fi
}

restore_backup() {
  local name="$1"
  local file="$BACKUP_DIR/$name"
  if [ -f "$file" ]; then
    cp "$file" "$BASH_PROFILE"
    log "✅ Restauration effectuée depuis : $file"
  else
    log "❌ Sauvegarde introuvable : $name"
  fi
}

list_backups() {
  ls -1 "$BACKUP_DIR" 2>/dev/null || log "Aucune sauvegarde disponible."
}

# ==========================================================
# Mise à jour locale
# ==========================================================

update_core() {
  log "🔄 Mise à jour du Core local..."
  git -C "$CORE_DIR" pull || log "⚠️  Impossible de mettre à jour localement."
}

# ==========================================================
# Mise à jour depuis GitHub (avec vérification SHA‑256)
# ==========================================================

upgrade_core() {
  log "⬆️  Mise à jour du Core depuis GitHub..."
  read -r -p "Souhaitez-vous vraiment télécharger et remplacer le Core depuis GitHub ? [o/N] " confirm
  if [[ "$confirm" != "o" && "$confirm" != "O" ]]; then
    log "❌ Opération annulée."
    return
  fi

  local tmp_script="/tmp/anthropic_core.sh"
  local tmp_hash="/tmp/anthropic_core.sh.sha256"

  log "⏳ Téléchargement du script..."
  curl -fsSL "$REMOTE_SCRIPT_URL" -o "$tmp_script" || { log "❌ Échec du téléchargement du script."; return; }

  log "⏳ Téléchargement du hash SHA‑256..."
  curl -fsSL "$REMOTE_HASH_URL" -o "$tmp_hash" || { log "❌ Échec du téléchargement du hash."; return; }

  log "🔐 Vérification de l’intégrité..."
  if shasum -a 256 -c "$tmp_hash" --status; then
    mv "$tmp_script" "$CORE_DIR/anthropic_core.sh"
    chmod +x "$CORE_DIR/anthropic_core.sh"
    log "✅ Vérification SHA‑256 réussie."
    log "✅ Core mis à jour depuis GitHub avec succès."
  else
    log "❌ Échec de la vérification SHA‑256. Fichier non remplacé."
  fi
}

# ==========================================================
# Publication automatique sur GitHub
# ==========================================================

publish_core() {
  cd "$CORE_DIR" || return
  shasum -a 256 anthropic_core.sh > anthropic_core.sh.sha256
  git add anthropic_core.sh anthropic_core.sh.sha256
  git commit -m "Publication automatique du Core CLI"
  git push origin main
  log "✅ Core publié sur GitHub avec succès."
}

# ==========================================================
# Statut et version
# ==========================================================

status_core() {
  log "=== Anthropic Core CLI (v$CORE_VERSION) ==="
  log "📦 Fichier : $CORE_DIR/anthropic_core.sh"
  log "📅 Dernière modification : $(date -r "$CORE_DIR/anthropic_core.sh")"
  log "👤 Utilisateur : $(whoami)"
  log "💻 Système : $(uname -a)"
  log "✅ Core opérationnel."
}

show_version() {
  log "Anthropic Core CLI – version $CORE_VERSION"
}

show_help() {
  cat <<EOF
=== Anthropic CLI (v$CORE_VERSION) ===
Commandes disponibles :
  backup                → crée une sauvegarde horodatée du .bash_profile
  restore-last-backup   → restaure la dernière sauvegarde
  restore <nom>         → restaure une sauvegarde précise
  list-backups          → affiche les sauvegardes disponibles
  update [--force]      → met à jour le Core local
  upgrade [--force]     → met à jour le Core depuis GitHub (avec SHA‑256)
  publish               → publie le Core et le hash sur GitHub
  status                → affiche le statut du Core
  version               → affiche la version du Core
  help                  → affiche cette aide
EOF
}

# ==========================================================
# Routeur de commandes
# ==========================================================

case "$1" in
  backup) backup_profile ;;
  restore-last-backup) restore_last_backup ;;
  restore) restore_backup "$2" ;;
  list-backups) list_backups ;;
  update) update_core ;;
  upgrade) upgrade_core ;;
  publish) publish_core ;;
  status) status_core ;;
  version) show_version ;;
  help|*) show_help ;;
esac
