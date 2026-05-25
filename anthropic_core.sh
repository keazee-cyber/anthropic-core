#!/usr/bin/env bash
# === Anthropic Core 1.0 ===

export ANTHRO_VERSION="1.0.0"
ANTH_HOME="$HOME/.anthropic_core"
LOG_DIR="$ANTH_HOME/logs"
mkdir -p "$LOG_DIR"

# === Étape 1 : Vérification du .bash_profile ===
check_balance() {
    echo "🔍 Vérification du fichier : $HOME/.bash_profile"
    local ifs=$(grep -cE '(^|[[:space:]])if[[:space:]]' "$HOME/.bash_profile" || true)
    local fis=$(grep -cE '(^|[[:space:]])fi([[:space:]]|$)' "$HOME/.bash_profile" || true)
    echo "if=$ifs fi=$fis"
    if [ "$ifs" -ne "$fis" ]; then
        echo "⚠️  Nombre de if/fi déséquilibré."
    else
        echo "✅ Blocs if/fi équilibrés"
    fi
}

# === Étape 2 : Sauvegarde du profil ===
backup_profile() {
    local src="$HOME/.bash_profile"
    local dest="$ANTH_HOME/backups"
    mkdir -p "$dest"
    local file="$dest/.bash_profile.backup.$(date +%Y%m%d_%H%M%S)"
    cp "$src" "$file"
    echo "✅ Sauvegarde créée : $file"
}

# === Étape 3 : Mise à jour du Core ===
update_self() {
    local backup="$ANTH_HOME/backup_${ANTHRO_VERSION}_$(date +%Y%m%d%H%M%S).tar.gz"
    tar -czf "$backup" "$ANTH_HOME"
    echo "✅ Sauvegarde du core créée : $backup"
    echo "🔄 (Simulation) Mise à jour réussie."
}

# === Étape 4 : Statut du projet Claude ===
anthropic_status() {
    local yaml_file="$HOME/claude_project.yaml"

    if [[ ! -f "$yaml_file" ]]; then
        echo "⚠️  Fichier $yaml_file introuvable."
        return 1
    fi

    echo "📊 Statut du projet Claude"
    echo "──────────────────────────────"

    awk '
    /^[[:space:]]*-/ {
        axis=$2
        getline
        if ($1=="score:") {
            score=$2
color="\033[0m"
if (score>=80) color="\033[1;32m"
else if (score>=50) color="\033[1;33m"
else color="\033[1;31m"
printf "%-25s → %s%s%%\033[0m\n", axis, color, score
        }
    }' "$yaml_file"

    echo "──────────────────────────────"
    echo "✅ Lecture terminée."
}

# === Gestion des commandes ===
case "$1" in
  check)   check_balance ;;
  backup)  backup_profile ;;
  update)  update_self ;;
  status)  anthropic_status ;;
  version) echo "Anthropic Core version $ANTHRO_VERSION" ;;
  *)
    echo "=== Anthropic CLI ==="
    echo "Commandes disponibles :"
    echo "  check     → vérifie la cohérence du .bash_profile"
    echo "  backup    → crée une sauvegarde horodatée du .bash_profile"
    echo "  update    → exécute la fonction update_self() du Core"
    echo "  status    → affiche le statut du projet Claude"
    echo "  version   → affiche la version du Core"
    echo
    echo "Exemple : anthropic check"
    ;;
esac

# ──────────────────────────────────────────────
# 📊 Fonction : anthropic_status
# ──────────────────────────────────────────────
anthropic_status() {
    echo "📊 Statut du projet Claude"
    echo "──────────────────────────────"
    local yaml_file="$HOME/claude_project.yaml"
    if [[ ! -f "$yaml_file" ]]; then
        echo "⚠️  Fichier $yaml_file introuvable."
        return 1
    fi

    # Exemple de lecture simple du YAML (si jq est dispo)
    if command -v yq >/dev/null 2>&1; then
        yq '.axes[] | "\(.nom): \(.score)%"' "$yaml_file"
    else
        echo "ℹ️  yq non installé — affichage brut :"
        cat "$yaml_file"
    fi

    echo "──────────────────────────────"
    echo "✅ Lecture terminée."
}

