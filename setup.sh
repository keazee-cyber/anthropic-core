#!/usr/bin/env bash
# ============================================================
# 🚀 Anthropic Core - Script d’installation et de configuration
# Auteur : Thierry Teplier (keazee-cyber)
# Version : 1.0.0
# ============================================================

set -e

CORE_DIR="$HOME/.anthropic_core"
VENV_DIR="$CORE_DIR/claude_env"
PROFILE="$HOME/.bash_profile"

echo "──────────────────────────────────────────────"
echo "🧠 Installation et configuration du Core Anthropic"
echo "──────────────────────────────────────────────"

# ------------------------------------------------------------
# 1️⃣ Vérification des dépendances système
# ------------------------------------------------------------
echo "🔍 Vérification des dépendances système..."

command -v brew >/dev/null 2>&1 || {
  echo "❌ Homebrew non trouvé. Installation recommandée :"
  echo '  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
  exit 1
}

command -v jq >/dev/null 2>&1 || {
  echo "📦 Installation de jq via Homebrew..."
  brew install jq
}

echo "✅ Dépendances système OK"
echo

# ------------------------------------------------------------
# 2️⃣ Création de l’environnement Python
# ------------------------------------------------------------
if [ ! -d "$VENV_DIR" ]; then
  echo "🐍 Création de l’environnement virtuel Python..."
  python3 -m venv "$VENV_DIR"
else
  echo "🐍 Environnement Python déjà présent."
fi

# Activation du venv
source "$VENV_DIR/bin/activate"

echo "✅ Environnement Python activé : $(python3 --version)"
echo

# ------------------------------------------------------------
# 3️⃣ Installation des dépendances Python
# ------------------------------------------------------------
REQ_FILE="$CORE_DIR/requirements.txt"
if [ -f "$REQ_FILE" ]; then
  echo "📦 Installation des dépendances Python..."
  pip install -r "$REQ_FILE"
else
  echo "⚠️ Aucun fichier requirements.txt trouvé — étape ignorée."
fi
echo

# ------------------------------------------------------------
# 4️⃣ Ajout des fonctions shell dans le .bash_profile
# ------------------------------------------------------------
if ! grep -q "function anthropic" "$PROFILE"; then
  echo "🔧 Ajout de la fonction 'anthropic' dans $PROFILE..."
  cat <<'EOF' >> "$PROFILE"

# ============================================================
# 🧠 Anthropic Core — Fonctions CLI
# ============================================================
function anthropic() {
    case "$1" in
        check)
            bash ~/.anthropic_core/anthropic_core.sh check
            ;;
        backup)
            bash ~/.anthropic_core/anthropic_core.sh backup
            ;;
        update)
            bash ~/.anthropic_core/anthropic_core.sh update
            ;;
        status)
            bash ~/.anthropic_core/anthropic_core.sh status
            ;;
        version)
            bash ~/.anthropic_core/anthropic_core.sh version
            ;;
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
}
EOF
  echo "✅ Fonction 'anthropic' ajoutée avec succès."
else
  echo "✅ Fonction 'anthropic' déjà présente dans ton profil."
fi

# ------------------------------------------------------------
# 5️⃣ Ajout de la fonction Nexus (complétion dynamique)
# ------------------------------------------------------------
if ! grep -q "function nexus" "$PROFILE"; then
  echo "🔧 Ajout de la fonction 'nexus' dans $PROFILE..."
  cat <<'EOF' >> "$PROFILE"

# ============================================================
# 🧩 Fonction Nexus — environnement complémentaire
# ============================================================
function nexus() {
    echo "🐍 Environnement Nexus prêt ✅ (fonction 'nexus' activée avec complétion dynamique)"
}
EOF
  echo "✅ Fonction 'nexus' ajoutée."
else
  echo "✅ Fonction 'nexus' déjà présente."
fi

# ------------------------------------------------------------
# 6️⃣ Vérification du profil bash
# ------------------------------------------------------------
echo
echo "🔍 Vérification du fichier : $PROFILE"
OPEN_BRACES=$(grep -o '{' "$PROFILE" | wc -l)
CLOSE_BRACES=$(grep -o '}' "$PROFILE" | wc -l)
IF_COUNT=$(grep -o '\<if\>' "$PROFILE" | wc -l)
FI_COUNT=$(grep -o '\<fi\>' "$PROFILE" | wc -l)

if [ "$OPEN_BRACES" -eq "$CLOSE_BRACES" ] && [ "$IF_COUNT" -eq "$FI_COUNT" ]; then
  echo "✅ Accolades { } équilibrées"
  echo "✅ Blocs if/fi équilibrés"
  echo
  echo "╔══════════════════════════════════╗"
  echo "║     🎉 PROFIL OK — aucune erreur     ║"
  echo "╚══════════════════════════════════╝"
else
  echo "❌ Erreur de syntaxe détectée dans $PROFILE"
fi
echo

# ------------------------------------------------------------
# 7️⃣ Résumé final
# ------------------------------------------------------------
echo "=== Anthropic CLI ==="
echo "Commandes disponibles :"
echo "  check     → vérifie la cohérence du .bash_profile"
echo "  backup    → crée une sauvegarde horodatée du .bash_profile"
echo "  update    → exécute la fonction update_self() du Core"
echo "  status    → affiche le statut du projet Claude"
echo "  version   → affiche la version du Core"
echo
echo "Exemple : anthropic check"
echo
echo "🚀 Installation terminée avec succès."
echo "➡️  Redémarre ton terminal ou exécute : source ~/.bash_profile"
echo "──────────────────────────────────────────────"
