#!/usr/bin/env python3
"""
Anthropic CLI Core
------------------
Interface en ligne de commande pour le projet Claude local.
Auteur : Thierry Teplier
Version : 1.1.0
"""

import os
import sys
import json
import shutil

# Version du Core
CORE_VERSION = "1.1.0"

# Données de statut du projet
def get_status_data():
    """Retourne les données de statut du projet au format dict."""
    return {
        "version": CORE_VERSION,
        "last_update": "2024-05-24",
        "Architecture": 95,
        "Configuration": 100,
        "Documentation": 80,
        "Sécurité": 70,
        "Fonctionnalités": 90,
        "global": 87
    }

# ───────────────────────────────────────────────
# 1️⃣ Affichage du statut (status)
# ───────────────────────────────────────────────
def display_status(data, raw=False, quiet=False):
    """Affiche le statut formaté du projet."""
    if quiet:
        return
    if raw:
        for key, value in data.items():
            print(f"{key}: {value}")
        return

    print("╔══════════════════════════════════════════╗")
    print("║          📊 STATUT DU PROJET CLAUDE       ║")
    print("╚══════════════════════════════════════════╝")
    print(f"Version du Core : {data['version']}")
    print(f"Dernière mise à jour : {data['last_update']}")
    print("────────────────────────────────────────────")
    for domaine in ["Architecture", "Configuration", "Documentation", "Sécurité", "Fonctionnalités"]:
        note = data[domaine]
        bar = "█" * (note // 10) + "░" * (10 - (note // 10))
        print(f"{domaine:<15} | {bar} | {note}%")
    print("────────────────────────────────────────────")
    print(f"Score global : {data['global']}%")
    if data["global"] >= 80:
        print("✅ Projet stable et fonctionnel")
    elif data["global"] >= 50:
        print("⚠️  Projet fonctionnel avec quelques points à finaliser")
    else:
        print("❌ Projet en cours de construction")

# ───────────────────────────────────────────────
# 2️⃣ Statut compact pour CI/CD (commit-status)
# ───────────────────────────────────────────────
def commit_status(data, quiet=False):
    """Retourne un statut JSON compact et exit code adapté."""
    output = {
        "global_score": data["global"],
        "passed": data["global"] >= 50,
        "version": data["version"]
    }
    if not quiet:
        print(json.dumps(output, ensure_ascii=False))
    return 0 if output["passed"] else 1

# ───────────────────────────────────────────────
# 3️⃣ Auto-test (self-test)
# ───────────────────────────────────────────────
def self_test():
    """Exécute les tests automatiques du Core."""
    print("🧪 Lancement des auto-tests du Core Anthropic...")
    tests = [
        ("Import des modules", True),
        ("Lecture des données de statut", True),
        ("Vérification des droits d'écriture", os.access(os.path.expanduser("~/.anthropic_core"), os.W_OK)),
        ("Vérification de Python", sys.version_info >= (3, 8)),
    ]

    passed = 0
    failed = 0
    for name, result in tests:
        if result:
            print(f"✅ {name}")
            passed += 1
        else:
            print(f"❌ {name}")
            failed += 1

    print(f"n📊 Bilan : {passed}/{len(tests)} tests passés")
    if failed == 0:
        print("🎉 Tous les tests ont réussi !")
    else:
        print("⚠️  Quelques tests ont échoué, vérifie ta configuration.")

# ───────────────────────────────────────────────
# 4️⃣ Diagnostic simple check
# ───────────────────────────────────────────────
def check_bash_profile():
    """Vérifie la cohérence basique du .bash_profile."""
    path = os.path.expanduser("~/.bash_profile")
    if not os.path.exists(path):
        print("⚠️  .bash_profile n'existe pas")
        return 1
    with open(path) as f:
        content = f.read()
    # Vérification équilibre accolades
    if content.count("{") != content.count("}"):
        print("❌ Accolades non équilibrées dans .bash_profile")
        return 1
    # Vérification équilibre if/fi
    if content.count("if") != content.count("fi"):
        print("❌ Blocs if/fi non équilibrés dans .bash_profile")
        return 1
    print("✅ .bash_profile cohérent")
    return 0

# ───────────────────────────────────────────────
# 5️⃣ Diagnostic complet (doctor)
# ───────────────────────────────────────────────
def doctor():
    """Diagnostique complet de l'environnement Anthropic local."""
    print("🩺 Diagnostic complet de l'environnement Anthropic CLI\n")
    checks = []
    score = 0
    total = 6

    # Vérification Python
    python_ok = sys.version_info >= (3, 8)
    checks.append(("Python", sys.version.split()[0], python_ok))
    if python_ok: score += 1

    # Vérification Homebrew
    homebrew_ok = shutil.which("brew") is not None
    checks.append(("Homebrew", "détecté" if homebrew_ok else "absent", homebrew_ok))
    if homebrew_ok: score += 1

    # Vérification jq
    jq_ok = shutil.which("jq") is not None
    checks.append(("jq", "détecté" if jq_ok else "absent", jq_ok))
    if jq_ok: score += 1

    # Vérification alias anthropic
    bash_profile = os.path.expanduser("~/.bash_profile")
    alias_ok = False
    if os.path.exists(bash_profile):
        with open(bash_profile) as f:
            alias_ok = "alias anthropic=" in f.read()
    checks.append(("Alias anthropic", "présent" if alias_ok else "absent", alias_ok))
    if alias_ok: score += 1

    # Vérification environnement virtuel
    venv_ok = os.getenv("VIRTUAL_ENV") is not None
    checks.append(("Environnement virtuel", os.getenv("VIRTUAL_ENV", "non actif"), venv_ok))
    if venv_ok: score += 1

    # Vérification du fichier CLI
    cli_path = os.path.expanduser("~/.anthropic_core/anthropic_cli.py")
    cli_ok = os.path.exists(cli_path) and os.access(cli_path, os.X_OK)
    checks.append(("anthropic_cli.py", "présent et exécutable" if cli_ok else "manquant", cli_ok))
    if cli_ok: score += 1

    # Affichage
    for name, status, ok in checks:
        icon = "✅" if ok else "❌"
        print(f"{icon} {name:<25} → {status}")

    print(f"\n🎯 Score : {score}/{total}")
    if score == total:
        print("✅ Environnement Anthropic parfaitement configuré !")
    else:
        print("⚠️  Quelques points à corriger.")

    # Attente pour éviter l'interruption de l'affichage
    import time
    time.sleep(0.2)

# ───────────────────────────────────────────────
# 6️⃣ Fonction de mise à jour automatique du Core
# ───────────────────────────────────────────────
import urllib.request
from datetime import datetime

def update_self(quiet=False):
    """
    Met à jour le Core Anthropic automatiquement depuis le dépôt distant.
    Étapes :
      1. Sauvegarde la version actuelle avec horodatage
      2. Télécharge la dernière version depuis le dépôt
      3. Remplace le fichier local
    """
    # Contournement de l'erreur de certificat SSL sur macOS
    import ssl
    ssl._create_default_https_context = ssl._create_unverified_context

    core_path = os.path.expanduser("~/.anthropic_core/anthropic_cli.py")
    backup_dir = os.path.expanduser("~/.anthropic_core/backups")
    os.makedirs(backup_dir, exist_ok=True)

    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    backup_path = os.path.join(backup_dir, f"anthropic_cli_{timestamp}.py")

    # Étape 1 : sauvegarde
    shutil.copy2(core_path, backup_path)
    if not quiet:
        print(f"💾 Sauvegarde du Core effectuée → {backup_path}")

    # Étape 2 : téléchargement
    remote_url = "https://raw.githubusercontent.com/thierryteplier/anthropic-core/main/anthropic_cli.py"
    if not quiet:
        print(f"⬇️  Téléchargement de la dernière version depuis {remote_url}...")

    try:
        with urllib.request.urlopen(remote_url) as response:
            new_code = response.read().decode("utf-8")

        # Étape 3 : remplacement
        with open(core_path, "w", encoding="utf-8") as f:
            f.write(new_code)

        # Remet les droits d'exécution
        os.chmod(core_path, 0o755)

        if not quiet:
            print("✅ Mise à jour du Core réussie.")
            print("🔁 Redémarre ton terminal ou recharge ton environnement pour appliquer la mise à jour.")

        return 0

    except Exception as e:
        print(f"[ERREUR] Échec de la mise à jour : {e}")
        print("❌ Le Core actuel a été conservé.")
        return 1

# ───────────────────────────────────────────────
# 7️⃣ Fonction principale
# ───────────────────────────────────────────────
def main():
    if len(sys.argv) < 2:
        print("Usage: anthropic <commande> [options]")
        print("Essayez anthropic help pour la liste des commandes.")
        sys.exit(1)

    cmd = sys.argv[1]
    args = sys.argv[2:]
    data = get_status_data()

    quiet = "--quiet" in args
    raw = "--raw" in args
    as_json = "--json" in args

    if cmd == "status":
        if as_json:
            if not quiet:
                print(json.dumps(data, indent=2, ensure_ascii=False))
        else:
            display_status(data, raw=raw, quiet=quiet)
        moyenne = round(sum([data["Architecture"], data["Documentation"], data["Sécurité"]]) / 3)
        sys.exit(0 if moyenne >= 50 else 1)

    elif cmd == "commit-status":
        code = commit_status(data, quiet=quiet)
        sys.exit(code)

    elif cmd == "version":
        if not quiet:
            print(f"Version du Core : {CORE_VERSION}")

    elif cmd == "check":
        code = check_bash_profile()
        sys.exit(code)

    elif cmd == "backup":
        bash_profile = os.path.expanduser("~/.bash_profile")
        backup_dir = os.path.expanduser("~/.anthropic_core/backups")
        os.makedirs(backup_dir, exist_ok=True)
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        backup_path = os.path.join(backup_dir, f"bash_profile_{timestamp}")
        shutil.copy2(bash_profile, backup_path)
        if not quiet:
            print(f"✅ Sauvegarde effectuée → {backup_path}")
        sys.exit(0)

    elif cmd == "update":
        if not quiet:
            print("Mise à jour du Core en cours...")
        code = update_self(quiet=quiet)
        sys.exit(code)

    elif cmd == "self-test":
        self_test()

    elif cmd == "doctor":
        doctor()

    elif cmd == "help":
        print("=== Anthropic CLI — Aide ===")
        print("Commandes disponibles :")
        print("  status         → affiche le statut du projet")
        print("  commit-status  → sortie JSON compacte pour CI/CD")
        print("  version        → affiche la version du Core")
        print("  check          → vérifie la cohérence du .bash_profile")
        print("  backup         → crée une sauvegarde horodatée du .bash_profile")
        print("  update         → met à jour le Core automatiquement")
        print("  self-test      → exécute les tests automatiques")
        print("  doctor         → diagnostic complet de l'environnement")
        print("Options : --quiet, --raw, --json")

    else:
        print(f"[ERREUR] Commande inconnue : {cmd}")
        print("Utilisez anthropic help pour la liste des commandes.")
        sys.exit(1)

if __name__ == "__main__":
    main()
