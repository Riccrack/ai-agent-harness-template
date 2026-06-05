#!/usr/bin/env bash
# init-harness.sh v2 — Bootstrap interactivo del AI Agent Harness.
#
# Wizard con 3 caminos:
#   💻 Local-only           — app que vive en tu compu, $0/mes
#   🌐 Vercel/Cloud         — managed para principiantes, $0 free tier
#   🚀 VPS Contabo          — comercial self-hosted, $5-$48+/mes
#
# Modos:
#   ./init-harness.sh              # standard (~18 preguntas, 8 min)
#   ./init-harness.sh --quick      # solo 5 esenciales
#   ./init-harness.sh --deep       # 18 + edge cases
#   ./init-harness.sh --simple     # v1 retro-compatible (sin wizard interactivo)
#
# Requisitos: bash, sed (Linux/macOS/WSL/Git Bash)

set -uo pipefail

# ─── Mode ─────────────────────────────────────────────────────────
MODE="standard"
case "${1:-}" in
  --quick)  MODE="quick" ;;
  --deep)   MODE="deep" ;;
  --simple) MODE="simple" ;;
  --help|-h)
    cat <<HELP
AI Agent Harness Template — bootstrap wizard

Usage:
  ./init-harness.sh              Standard wizard (~18 questions, 8 min)
  ./init-harness.sh --quick      Quick mode (5 essential questions)
  ./init-harness.sh --deep       Deep mode (18 + edge cases like i18n, multi-tenant, etc.)
  ./init-harness.sh --simple     Simple mode (project name only, v1 retro-compatible)
  ./init-harness.sh --help       This help

Output: ./docs/ with 8-17 markdown skeletons (depending on path chosen)
HELP
    exit 0
    ;;
esac

# ─── Colors ───────────────────────────────────────────────────────
if [[ -t 1 ]] && command -v tput >/dev/null 2>&1; then
  BOLD=$(tput bold); DIM=$(tput dim)
  GREEN=$(tput setaf 2); YELLOW=$(tput setaf 3); RED=$(tput setaf 1)
  BLUE=$(tput setaf 4); CYAN=$(tput setaf 6); MAGENTA=$(tput setaf 5)
  RESET=$(tput sgr0)
else
  BOLD="" DIM="" GREEN="" YELLOW="" RED="" BLUE="" CYAN="" MAGENTA="" RESET=""
fi

# ─── Detect script dir + skeleton ─────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKELETON_DIR="$SCRIPT_DIR/harness-skeleton"
CONFIGS_DIR="$SCRIPT_DIR/starter-configs"

if [[ ! -d "$SKELETON_DIR" ]]; then
  echo "${RED}❌ No encontré $SKELETON_DIR${RESET}"
  echo "Asegurate de correr esto desde el directorio del template."
  exit 1
fi

# ─── Answers store ────────────────────────────────────────────────
declare -A A

# ─── Helpers ──────────────────────────────────────────────────────

heading() {
  echo ""
  echo "${BOLD}${MAGENTA}═══════════════════════════════════════════════════════════${RESET}"
  echo "${BOLD}${MAGENTA}  $1${RESET}"
  echo "${BOLD}${MAGENTA}═══════════════════════════════════════════════════════════${RESET}"
  echo ""
}

ask_text() {
  local key="$1" prompt="$2" default="${3:-}"
  echo "${BOLD}${CYAN}? ${prompt}${RESET}"
  [[ -n "$default" ]] && echo "${DIM}  (default: $default — Enter para usarlo)${RESET}"
  read -r -p "${CYAN}  > ${RESET}" val
  A[$key]="${val:-$default}"
  echo ""
}

ask_multiline() {
  local key="$1" prompt="$2"
  echo "${BOLD}${CYAN}? ${prompt}${RESET}"
  echo "${DIM}  (varias líneas; línea vacía + Enter para terminar)${RESET}"
  local lines="" line
  while IFS= read -r -p "${CYAN}  > ${RESET}" line; do
    [[ -z "$line" ]] && break
    lines="${lines}${line}"$'\n'
  done
  A[$key]="$lines"
  echo ""
}

ask_choice() {
  local key="$1" prompt="$2"
  shift 2
  local options=("$@")
  echo "${BOLD}${CYAN}? ${prompt}${RESET}"
  local i=1
  for opt in "${options[@]}"; do
    echo "  ${BOLD}$i)${RESET} $opt"
    ((i++))
  done
  local choice
  read -r -p "${CYAN}  Opción [1-${#options[@]}]: ${RESET}" choice
  choice=${choice:-1}
  A[$key]="$choice"
  A[${key}_LABEL]="${options[$((choice-1))]}"
  echo ""
}

ask_multi() {
  local key="$1" prompt="$2"
  shift 2
  local options=("$@")
  echo "${BOLD}${CYAN}? ${prompt}${RESET}"
  echo "${DIM}  (separadas por coma, ej: 1,3,5)${RESET}"
  local i=1
  for opt in "${options[@]}"; do
    echo "  ${BOLD}$i)${RESET} $opt"
    ((i++))
  done
  local choice
  read -r -p "${CYAN}  Tus opciones: ${RESET}" choice
  A[$key]="${choice:-none}"
  echo ""
}

# ═══════════════════════════════════════════════════════════════════
#  MODO --simple: fallback retro-compatible v1
# ═══════════════════════════════════════════════════════════════════
if [[ "$MODE" == "simple" ]]; then
  PROJECT_NAME="${2:-MiApp}"
  OWNER="${OWNER:-$(git config user.name 2>/dev/null || echo 'Owner')}"
  TODAY=$(date -u +%Y-%m-%d)
  TARGET_DIR="$(pwd)/docs"

  mkdir -p "$TARGET_DIR"

  # Solo copia base docs (13 originales)
  for f in active-context decisions glossary integrations known-issues lessons-learned pendientes product-context progress runbook security system-patterns tech-context; do
    [[ -f "$SKELETON_DIR/${f}.md" ]] && cp "$SKELETON_DIR/${f}.md" "$TARGET_DIR/"
  done
  [[ -f "$SKELETON_DIR/README.md" ]] && cp "$SKELETON_DIR/README.md" "$TARGET_DIR/"

  SED_ARGS=(-i)
  [[ "$(uname -s)" == "Darwin" ]] && SED_ARGS=(-i '')
  find "$TARGET_DIR" -maxdepth 1 -type f -name '*.md' -exec sed "${SED_ARGS[@]}" \
    -e "s/{{PROJECT_NAME}}/$PROJECT_NAME/g" \
    -e "s/{{YYYY-MM-DD}}/$TODAY/g" \
    -e "s/{{OWNER}}/$OWNER/g" \
    {} \;

  echo "${GREEN}✅ Modo simple: 13 docs base en $TARGET_DIR${RESET}"
  exit 0
fi

# ═══════════════════════════════════════════════════════════════════
#  INTRO
# ═══════════════════════════════════════════════════════════════════
clear 2>/dev/null || true
cat << EOF
${BOLD}${BLUE}🤖 AI Agent Harness — Bootstrap wizard${RESET}
${DIM}   Te preparo el proyecto en ~8 min para que tu agente AI (Claude Code,${RESET}
${DIM}   Cursor, Cline, etc.) entienda tu app sin que se lo expliques.${RESET}

Modo: ${BOLD}${GREEN}${MODE}${RESET}

${DIM}Tips:${RESET}
  ${DIM}• 'no sé' es respuesta válida — yo te dejo un TODO para discutir con tu agente${RESET}
  ${DIM}• Ctrl+C cancela en cualquier momento${RESET}

EOF
read -r -p "${CYAN}¿Empezamos? [Enter]${RESET} "

# ═══════════════════════════════════════════════════════════════════
#  ETAPA 1 — SOBRE TU APP
# ═══════════════════════════════════════════════════════════════════
heading "🌟 Etapa 1 — Sobre tu app"

# P1: Nombre
ask_text P1 "¿Cómo se va a llamar tu proyecto?" "MiApp"

# P2: Descripción multilínea (la pregunta clave)
echo "${BOLD}${YELLOW}💡 Esta es la pregunta MÁS importante del wizard.${RESET}"
echo "${DIM}   Lo que escribas va a ser el contexto principal de tu agente AI.${RESET}"
echo ""
ask_multiline P2 "Describí tu app en 2-3 oraciones (qué hace, para quién, por qué importa)"

# P3: Dispositivo
ask_choice P3 "¿En qué dispositivos van a usar tu app?" \
  "🌐 Web (navegador en PC y celular)" \
  "📱 App móvil nativa Android + iOS" \
  "💻 Escritorio (Windows/Mac/Linux)" \
  "🤖 Bot (Telegram/Discord/WhatsApp — sin interfaz)" \
  "🔌 Solo API (sin frontend)" \
  "🧩 Extensión de navegador" \
  "🤔 No sé / decidan ustedes"

# P4: LA BIFURCACIÓN MAESTRA
ask_choice P4 "¿Vas a vender esta app a otros, o es para uso personal?" \
  "🏠 Personal (uso propio, hobby, aprender, portfolio)" \
  "🚀 Para vender (SaaS, app comercial, clientes pagando)" \
  "🏢 Para mi negocio interno / clientes específicos" \
  "🤔 No estoy seguro / decido más tarde"

# ═══════════════════════════════════════════════════════════════════
#  BIFURCACIÓN — PATH PERSONAL vs COMERCIAL
# ═══════════════════════════════════════════════════════════════════
case "${A[P4]}" in
  1)
    # Path Personal — preguntar Local vs Vercel
    ask_choice P4B "Como es personal, ¿dónde la vas a correr?" \
      "💻 Solo en mi computadora (\$0 costo, sin internet necesario)" \
      "🌐 En Vercel/Netlify (gratis, URL pública en 5 min)" \
      "🤔 No sé / explícame las opciones"
    case "${A[P4B]}" in
      1) PATH_TYPE="local" ;;
      2) PATH_TYPE="vercel" ;;
      *)
        echo "${YELLOW}Te recomiendo Vercel — es más fácil para principiantes${RESET}"
        echo "${DIM}(local parece simple pero compartir con alguien requiere más config)${RESET}"
        PATH_TYPE="vercel"
        ;;
    esac
    ;;
  2|3)
    # Path Comercial — preguntar budget
    PATH_TYPE="vps"
    echo "${BOLD}${GREEN}🚀 Path comercial — vas a usar VPS self-hosted (patrón Publiafy)${RESET}"
    echo ""
    ask_choice P4C "¿Cuál es tu budget mensual de infraestructura?" \
      "💰 Lo más barato (\$5-7/mes — Cloud VPS 10, aguanta hasta 200 users)" \
      "💰💰 Algo más holgado (\$15-20/mes — Cloud VPS 30, hasta 800 users)" \
      "💰💰💰 Performance dedicada (\$48/mes — VDS M, hasta 2000 users)" \
      "🤔 No sé → arrancá con \$5-7/mes y upgradeás cuando crezcas"
    ;;
  4|*)
    # No sé — defaultea a Vercel con upgrade path documentado
    echo "${YELLOW}Sin problema. Te configuro path Vercel con upgrade documentado.${RESET}"
    PATH_TYPE="vercel"
    ;;
esac

A[PATH_TYPE]="$PATH_TYPE"

# Vercel warning si crece
if [[ "$PATH_TYPE" == "vercel" && "${A[P4]}" == "2" ]]; then
  echo ""
  echo "${YELLOW}⚠️  ALERTA — vas a vender Y elegiste Vercel:${RESET}"
  echo "${YELLOW}    Vercel + Supabase + Clerk juntos cuestan ~\$70-300/mes${RESET}"
  echo "${YELLOW}    cuando tu app crezca. Para apps comerciales serias considerá${RESET}"
  echo "${YELLOW}    el path VPS desde día 1 (\$5/mes fijo).${RESET}"
  echo ""
  ask_choice P4D "¿Querés cambiar a path VPS antes de seguir?" \
    "No, sigo con Vercel (después puedo migrar)" \
    "Sí, cambiame a VPS desde ya"
  if [[ "${A[P4D]}" == "2" ]]; then
    PATH_TYPE="vps"
    A[PATH_TYPE]="vps"
    ask_choice P4C "¿Cuál es tu budget mensual?" \
      "💰 \$5-7/mes — Cloud VPS 10 (arranque)" \
      "💰💰 \$15-20/mes — Cloud VPS 30" \
      "💰💰💰 \$48/mes — VDS M (performance dedicada)"
  fi
fi

# Quick mode termina acá
if [[ "$MODE" == "quick" ]]; then
  # Salta P5-P18 con defaults razonables
  A[P5]="(no respondida — quick mode)"
  A[P6]="(definir con agente AI)"
  A[P7]="6"  # Solo datos públicos por defecto
  A[P8]="2"  # Aprendiendo
  A[P8_LABEL]="Aprendiendo — sé lo básico"
  A[P9]="1"  # Claude Code
  A[P9_LABEL]="Claude Code (terminal o VS Code)"
  A[P10]="9"  # Global
  A[P10_LABEL]="Global / múltiples países"
  A[P11]="3"  # Decido más tarde
  A[P11_LABEL]="Decido más adelante con mi agente AI"
  A[P17]="1"  # Git init
  A[P18]="1"  # Agent file
else

# ═══════════════════════════════════════════════════════════════════
#  ETAPA 2 — FEATURES + AUDIENCIA
# ═══════════════════════════════════════════════════════════════════
heading "🎯 Etapa 2 — Qué va a hacer"

ask_text P5 "¿Quiénes la van a usar?" "no sé todavía"
ask_multiline P6 "Listá las 3 features más importantes para v1 (una por línea)"

ask_multi P7 "¿Maneja datos sensibles? (multi-select)" \
  "Datos personales básicos (nombre, email)" \
  "Pagos / tarjetas de crédito" \
  "Datos médicos / salud" \
  "Datos de menores de 18 años" \
  "Datos financieros / bancarios" \
  "Solo datos públicos" \
  "No sé todavía"

# ═══════════════════════════════════════════════════════════════════
#  ETAPA 3 — SOBRE VOS
# ═══════════════════════════════════════════════════════════════════
heading "👤 Etapa 3 — Sobre vos"

ask_choice P8 "¿Cuál es tu nivel programando?" \
  "Nunca programé — la IA es mi compañera" \
  "Aprendiendo — sé lo básico" \
  "Junior/Intermedio (1-3 años)" \
  "Senior (3+ años)" \
  "Prefiero no decir"

ask_choice P9 "¿Con qué agente AI vas a trabajar?" \
  "Claude Code (terminal o VS Code)" \
  "Claude Code Desktop (app Mac/Windows)" \
  "Cursor" \
  "Cline (extensión VS Code)" \
  "Antigravity (Google)" \
  "Aider (terminal)" \
  "Continue.dev" \
  "Varios / aún no decido"

ask_choice P10 "¿En qué país opera principalmente tu app?" \
  "Argentina" "México" "España" "Colombia" "Chile" \
  "Otro LATAM" "USA/Canada" "Europa (no España)" "Global / múltiples"

# P9.5 — Plugins/skills recomendados para Claude Code (skip si no usa Claude Code)
if [[ "${A[P9]:-1}" == "1" || "${A[P9]:-1}" == "2" ]]; then
  ask_choice P9P "🔌 ¿Querés sugerencias de plugins para tu Claude Code? (battle-tested 2026)" \
    "⭐ Top 3 esenciales (Superpowers + Frontend Design + Context7)" \
    "⭐⭐ Full vibecoding (top 3 + UI/UX Pro Max + claude-mem session memory)" \
    "Solo info en CLAUDE.md (los instalo después)" \
    "No, gracias"
fi

# ═══════════════════════════════════════════════════════════════════
#  ETAPA 4 — STACK + STARTER
# ═══════════════════════════════════════════════════════════════════
heading "🛠️ Etapa 4 — Stack técnico"

ask_choice P11 "¿Sabés qué tecnologías vas a usar?" \
  "Sí, ya sé qué stack quiero" \
  "No, recomendame uno" \
  "Decido más adelante con mi agente AI"

fi  # fin no-quick

# Sugerencia de starter — depende del PATH_TYPE
heading "🎁 Recomendación de starter / boilerplate"

case "$PATH_TYPE" in
  local)
    echo "${DIM}Para path local-only, no necesitás starter complejo.${RESET}"
    echo "${DIM}Tu agente AI va a crear el código desde cero a partir de tu descripción.${RESET}"
    ;;
  vercel)
    case "${A[P3]}" in
      1) # Web
        ask_choice P12 "Recomendaciones para web + Vercel:" \
          "Next.js + Supabase + Clerk (vanilla, fácil)" \
          "ixartz/SaaS-Boilerplate (GRATIS MIT, 7.2k⭐, AGENTS.md pre-armado)" \
          "Kiranism/next-shadcn-dashboard-starter (GRATIS MIT, 6.5k⭐, dashboard B2B)" \
          "vercel/commerce (GRATIS MIT, e-commerce con Shopify)" \
          "onwidget/astrowind (GRATIS MIT, landing+blog en Astro)" \
          "Empiezo de cero (tu agente AI te guía)"
        ;;
      2) # Móvil
        ask_choice P12 "Recomendaciones para móvil:" \
          "Ignite (Infinite Red — 19.8k⭐ MIT, RN+Expo+TS, sin auth/DB built-in)" \
          "obytes/react-native-template-obytes (4.2k⭐ MIT, RN+Expo minimal)" \
          "Expo router templates oficiales" \
          "Empiezo de cero"
        ;;
      3) # Desktop
        ask_choice P12 "Recomendaciones para desktop:" \
          "Tauri (Rust + web tech — binarios ~5MB)" \
          "electron-react-boilerplate (Electron clásico — más pesado pero mainstream)" \
          "Empiezo de cero"
        ;;
      4) # Bot
        ask_choice P12 "Recomendaciones para bots:" \
          "Telegram: bot-base/telegram-bot-template (TS + Telegraf + DB + i18n)" \
          "Discord: discord.js boilerplate oficial" \
          "WhatsApp: Baileys (⚠️ riesgo de ban — usar oficial WABA si serio)" \
          "Empiezo de cero"
        ;;
      6) # Extensión
        ask_choice P12 "Recomendaciones para extensión browser:" \
          "JohnBra/vite-web-extension (Vite + React + Manifest v3)" \
          "Plasmo Framework (más declarativo)" \
          "Empiezo de cero"
        ;;
      *)
        echo "${DIM}Sin recomendación específica para tu tipo de app.${RESET}"
        A[P12]="0"
        ;;
    esac
    ;;
  vps)
    case "${A[P3]}" in
      1)
        ask_choice P12 "Recomendaciones para path VPS comercial:" \
          "publiafy-stack-template (battle-tested patrón Publiafy — Node+Postgres+Redis+Traefik)" \
          "Empiezo de cero con docker-stack.yml básico (genero template)" \
          "Otro template (vos decidís)"
        ;;
      *)
        echo "${DIM}Para tu tipo de app + path VPS, vamos con docker-stack.yml básico.${RESET}"
        A[P12]="2"
        ;;
    esac
    ;;
esac

# Monetización (solo si vendiendo)
if [[ "${A[P4]:-}" == "2" || "${A[P4]:-}" == "3" ]]; then
  heading "💰 Etapa 5 — Monetización"
  ask_choice P14 "¿Cómo vas a cobrar?" \
    "Suscripción mensual" "Suscripción anual" "Pago único" "Freemium" "Free todavía"
  ask_choice P15 "¿Procesador de pagos?" \
    "Stripe (global)" "Mercado Pago (LATAM)" "PayPal" "Lemon Squeezy (MoR)" "Polar (OSS)" "No sé"
  ask_choice P16 "¿Moneda principal?" "USD" "MXN" "ARS" "EUR" "Múltiples"
fi

# ═══════════════════════════════════════════════════════════════════
#  ETAPA EXTRA — Solo en modo DEEP
# ═══════════════════════════════════════════════════════════════════
if [[ "$MODE" == "deep" ]]; then
  heading "🔍 Edge cases avanzados"
  ask_choice D1 "¿Múltiples idiomas?" "No, solo uno" "Sí desde día 1" "Quizás después"
  ask_choice D2 "¿Multi-tenant (cada cliente datos separados)?" "No" "Sí" "No sé qué significa"
  ask_choice D3 "¿Tiempo real (chat, notificaciones live)?" "No" "Sí" "No sé"
  ask_choice D4 "¿Usuarios suben archivos pesados (>10MB)?" "No" "Pocos chicos" "Muchos/pesados"
  ask_choice D5 "¿Vas a mandar emails?" "No" "Sí (Resend recomendado)" "Volumen alto"
  ask_choice D6 "¿IA generativa interna?" \
    "No" "Sí, chat con LLM" "Sí, RAG (con tus docs)" "Sí, agentes con tools" "Sí, generación de imágenes"
  ask_choice D7 "¿Testing automático?" "Ninguno" "Unit básico" "Unit+integración" "Completo con E2E"
  ask_choice D8 "¿Monitoreo de errores desde día 1?" "No, después" "Sí, Sentry" "Sí, alternativa OSS"
fi

# ═══════════════════════════════════════════════════════════════════
#  ETAPA 6 — SETUP TÉCNICO
# ═══════════════════════════════════════════════════════════════════
if [[ "$MODE" != "quick" ]]; then
  heading "⚙️ Etapa 6 — Setup técnico"
  ask_choice P17 "¿Inicializar git automáticamente?" \
    "Sí, git init + primer commit" \
    "Ya tengo git acá" \
    "No, lo hago a mano"
  ask_choice P18 "¿Crear archivo de config de tu agente AI?" \
    "Sí, con instrucciones para leer docs/ al iniciar" \
    "Sí pero vacío para que llene yo" \
    "No"
fi

# Owner detect
OWNER="${OWNER:-}"
if [[ -z "$OWNER" ]]; then
  GIT_NAME=$(git config user.name 2>/dev/null || echo "")
  OWNER="${GIT_NAME:-Anonymous}"
fi

# ═══════════════════════════════════════════════════════════════════
#  RESUMEN + CONFIRMACIÓN
# ═══════════════════════════════════════════════════════════════════
heading "📋 Resumen — esto voy a generar"

PROJECT_NAME="${A[P1]}"

cat << EOF
${BOLD}Tu proyecto:${RESET}
  Nombre:        ${PROJECT_NAME}
  Owner:         ${OWNER}
  Plataforma:    ${A[P3_LABEL]:-—}
  Propósito:     ${A[P4_LABEL]:-—}

${BOLD}Path elegido:${RESET}
  ${GREEN}${PATH_TYPE}${RESET}
EOF

case "$PATH_TYPE" in
  local)   echo "    💻 Desarrollo local + opciones para compartir (ngrok/Tailscale)" ;;
  vercel)  echo "    🌐 Vercel deploy + servicios managed (Supabase, Clerk, Resend)" ;;
  vps)
    echo "    🚀 VPS Contabo self-hosted (patrón Publiafy)"
    echo "    💸 Budget tier: ${A[P4C_LABEL]:-arranque}"
    ;;
esac

cat << EOF

${BOLD}Docs que voy a crear:${RESET}
EOF

# Determinar docs a copiar según path
BASE_DOCS=(active-context decisions glossary known-issues pendientes product-context progress runbook tech-context)
case "$PATH_TYPE" in
  local)
    EXTRA_DOCS=(local-setup)
    echo "  • 8 docs base: product-context, tech-context, decisions, active-context, progress, known-issues, pendientes, runbook"
    echo "  • + local-setup.md (cómo correrlo en tu máquina)"
    ;;
  vercel)
    EXTRA_DOCS=(integrations deploy-to-vercel cloud-services-costs)
    echo "  • 9 docs base"
    echo "  • + deploy-to-vercel.md (guía paso-a-paso)"
    echo "  • + cloud-services-costs.md (qué cuesta cuando crece)"
    echo "  • + integrations.md (Supabase + Clerk + Resend setup)"
    ;;
  vps)
    EXTRA_DOCS=(integrations security system-patterns lessons-learned infrastructure disaster-recovery monitoring costs)
    echo "  • 13 docs base"
    echo "  • + infrastructure.md (topología real)"
    echo "  • + disaster-recovery.md (backups + restore)"
    echo "  • + monitoring.md (uptime + alertas)"
    echo "  • + costs.md (tracking mensual)"
    echo "  • + security.md, integrations.md, system-patterns.md, lessons-learned.md"
    ;;
esac

if [[ "$PATH_TYPE" == "vps" ]]; then
  echo ""
  echo "${BOLD}Archivos de config (Publiafy-pattern):${RESET}"
  echo "  • docker-stack.yml.template (Postgres + Redis + Traefik + app)"
  echo "  • Dockerfile.template (multi-stage)"
  echo "  • backup.sh + restore.sh (DB + uploads automático)"
  echo "  • setup-secrets.sh (Docker Swarm secrets)"
  echo "  • .env.example (vars completas)"
fi

echo ""
read -r -p "${CYAN}¿Continúo? [Y/n]: ${RESET}" CONFIRM
if [[ "${CONFIRM:-y}" =~ ^[Nn]$ ]]; then
  echo "Cancelado."
  exit 0
fi

# ═══════════════════════════════════════════════════════════════════
#  BOOTSTRAP
# ═══════════════════════════════════════════════════════════════════
echo ""
echo "${DIM}🔧 Creando docs/ ...${RESET}"

TARGET_DIR="$(pwd)/docs"
mkdir -p "$TARGET_DIR"

# Copiar README del harness
[[ -f "$SKELETON_DIR/README.md" ]] && cp "$SKELETON_DIR/README.md" "$TARGET_DIR/"

# Copiar base docs
for f in "${BASE_DOCS[@]}"; do
  [[ -f "$SKELETON_DIR/${f}.md" ]] && cp "$SKELETON_DIR/${f}.md" "$TARGET_DIR/"
done

# Copiar path-specific docs
for f in "${EXTRA_DOCS[@]}"; do
  [[ -f "$SKELETON_DIR/${f}.md" ]] && cp "$SKELETON_DIR/${f}.md" "$TARGET_DIR/"
done

# Copiar starter-configs si es VPS
if [[ "$PATH_TYPE" == "vps" && -d "$CONFIGS_DIR/vps" ]]; then
  echo "${DIM}🔧 Copiando starter-configs/vps/ a raíz del proyecto...${RESET}"
  for f in "$CONFIGS_DIR/vps"/*.template "$CONFIGS_DIR/vps"/*.sh "$CONFIGS_DIR/vps"/.env.example; do
    [[ -f "$f" ]] || continue
    base=$(basename "$f")
    # Quitar .template extension
    base="${base%.template}"
    cp "$f" "$(pwd)/$base"
  done
elif [[ "$PATH_TYPE" == "vercel" && -d "$CONFIGS_DIR/vercel" ]]; then
  cp "$CONFIGS_DIR/vercel/.env.example" "$(pwd)/" 2>/dev/null || true
  cp "$CONFIGS_DIR/vercel/vercel.json" "$(pwd)/" 2>/dev/null || true
elif [[ "$PATH_TYPE" == "local" && -d "$CONFIGS_DIR/local" ]]; then
  cp "$CONFIGS_DIR/local/.env.example" "$(pwd)/" 2>/dev/null || true
fi

# ─── Reemplazar placeholders ────────────────────────────────────
TODAY=$(date -u +%Y-%m-%d)
SED_ARGS=(-i)
[[ "$(uname -s)" == "Darwin" ]] && SED_ARGS=(-i '')

echo "${DIM}🔧 Reemplazando placeholders...${RESET}"
find "$TARGET_DIR" -maxdepth 1 -type f -name '*.md' -exec sed "${SED_ARGS[@]}" \
  -e "s/{{PROJECT_NAME}}/$PROJECT_NAME/g" \
  -e "s/{{YYYY-MM-DD}}/$TODAY/g" \
  -e "s/{{OWNER}}/$OWNER/g" \
  {} \;

# Reemplazar también en configs de raíz
find "$(pwd)" -maxdepth 1 -type f \( -name '*.yml' -o -name '*.sh' -o -name '.env*' -o -name 'Dockerfile' \) -exec sed "${SED_ARGS[@]}" \
  -e "s/{{PROJECT_NAME}}/$PROJECT_NAME/g" \
  -e "s/{{OWNER}}/$OWNER/g" \
  {} \; 2>/dev/null || true

# ─── Pre-fill product-context.md con la descripción del user ───
PRODUCT_CTX="$TARGET_DIR/product-context.md"
if [[ -f "$PRODUCT_CTX" && -n "${A[P2]:-}" ]]; then
cat > "$PRODUCT_CTX" << EOF
# 📦 product-context.md — Qué es $PROJECT_NAME

> **Última actualización**: $TODAY
> **Audiencia**: agentes de IA + stakeholders.
> **Propósito**: visión del producto, audiencia, modelo de negocio.

---

## ¿Qué es $PROJECT_NAME?

${A[P2]}

## ¿Para qué es?

${A[P4_LABEL]:-Por definir}

## ¿Quiénes la van a usar?

${A[P5]:-Por definir}

## Features prioritarias para v1

${A[P6]:-Por definir con agente AI}

## Modelo de negocio

EOF
  case "${A[P4]:-}" in
    1) echo "Personal / no comercial. Si después se decide vender, ver \`decisions.md\`." >> "$PRODUCT_CTX" ;;
    2) echo "Comercial — SaaS / app pública. Modelo de cobro: ${A[P14_LABEL]:-por definir}." >> "$PRODUCT_CTX" ;;
    3) echo "Comercial — negocio interno / clientes específicos." >> "$PRODUCT_CTX" ;;
    *) echo "Por definir — agregar entry en \`decisions.md\` cuando se decida." >> "$PRODUCT_CTX" ;;
  esac
fi

# ─── ADR-001 stub ────────────────────────────────────────────────
ADR_FILE="$TARGET_DIR/decisions.md"
cat > "$ADR_FILE" << EOF
# 🧭 decisions.md — Architecture Decision Records (ADRs)

> **Última actualización**: $TODAY

---

## ADR-001: Path de infraestructura — $PATH_TYPE

**Date**: $TODAY
**Status**: Accepted
**Severity**: Foundational

### Context

$PROJECT_NAME arranca con esta decisión sobre **dónde va a vivir la app**.

Resumen de la app: ${A[P2]:-(por completar)}

### Decision

**Path elegido**: \`$PATH_TYPE\`

EOF

case "$PATH_TYPE" in
  local)
    cat >> "$ADR_FILE" << EOF
La app corre solo en la computadora del owner durante el desarrollo.

**Stack default**:
- Runtime local (Node.js / Python / etc.)
- DB: SQLite (en archivo local)
- Sin reverse proxy, sin SSL (localhost no lo necesita)

**Para compartir con otros**: ngrok / Tailscale / Cloudflare Tunnel.

**Costo**: \$0/mes.
EOF
    ;;
  vercel)
    cat >> "$ADR_FILE" << EOF
Deploy en Vercel (managed) con servicios cloud asociados:
- DB: Supabase (Postgres managed)
- Auth: Clerk
- Email: Resend

**Costo arranque**: \$0/mes (free tier de todos los servicios).

**Riesgo conocido**: costos escalan agresivamente al crecer
(~\$70-300/mes apenas pasás free tiers). Ver \`cloud-services-costs.md\`.

**Upgrade path documentado**: cuando facturas managed > \$50/mes sostenido,
migrar a path VPS (\`harness upgrade --to=vps\`).
EOF
    ;;
  vps)
    cat >> "$ADR_FILE" << EOF
Self-hosted en VPS con stack patrón Publiafy.

**Stack default**:
- VPS: Contabo (tier inicial ${A[P4C_LABEL]:-Cloud VPS 10 \$5-7/mes})
- DB: Postgres en Docker (volumen persistente)
- Cache/queues: Redis en Docker
- Reverse proxy: Traefik con auto-SSL Let's Encrypt
- Orchestración: Docker Swarm
- Backups: diarios a Backblaze B2

**Costo arranque**: ~\$6/mes fijo (VPS + dominio + B2).
Escala con upgrades de plan documentados en \`costs.md\`.

**Trade-off aceptado**: somos el ops team. A cambio: costos predecibles,
ownership total, zero vendor lock-in.
EOF
    ;;
esac

cat >> "$ADR_FILE" << EOF

### Alternatives considered

- TODO: completar con qué OTROS paths se evaluaron y por qué este ganó.

### Consequences

- ✅ TODO: beneficios concretos
- ⚠️ TODO: trade-offs aceptados
- 🚫 TODO: cosas que YA NO podemos hacer fácil

---
EOF

# ─── Active-context inicial ─────────────────────────────────────
cat > "$TARGET_DIR/active-context.md" << EOF
# 🎯 active-context.md — Lo que estamos haciendo AHORA

> **Última actualización**: $TODAY

---

## Update $TODAY — Bootstrap de $PROJECT_NAME

**Estado**: ⏳ inicial · path: $PATH_TYPE

### Qué se hizo
- Bootstrap del AI Agent Harness con path \`$PATH_TYPE\`
- Docs base + path-specific creados
- ADR-001 con la decisión de infra (pendiente completar alternatives + consequences)
EOF

if [[ "$PATH_TYPE" == "vps" ]]; then
  cat >> "$TARGET_DIR/active-context.md" << EOF
- Configs Docker generados en raíz: docker-stack.yml + Dockerfile + backup.sh
EOF
fi

cat >> "$TARGET_DIR/active-context.md" << EOF

### Próximos pasos
- Completar product-context.md con detalle de audiencia + modelo de negocio
- Completar ADR-001 (alternatives + consequences)
- Empezar a codear con tu agente AI
EOF

if [[ "$PATH_TYPE" == "vps" ]]; then
  cat >> "$TARGET_DIR/active-context.md" << EOF
- Provisionar VPS Contabo + cargar secrets (ver \`setup-secrets.sh\`)
- Primer deploy: \`docker stack deploy -c docker-stack.yml $PROJECT_NAME\`
EOF
elif [[ "$PATH_TYPE" == "vercel" ]]; then
  cat >> "$TARGET_DIR/active-context.md" << EOF
- Push a GitHub → import en Vercel → primer deploy
- Crear cuentas Supabase + Clerk + Resend
- Agregar env vars en Vercel Settings
EOF
else
  cat >> "$TARGET_DIR/active-context.md" << EOF
- Setup local: \`cp .env.example .env\` + \`npm install\` + \`npm run dev\`
EOF
fi

cat >> "$TARGET_DIR/active-context.md" << EOF

---
EOF

# ─── Progress.md inicial ──────────────────────────────────────────
cat > "$TARGET_DIR/progress.md" << EOF
# ✅ progress.md — Qué funciona vs qué está pendiente

> **Última actualización**: $TODAY

---

## Época 0 — Bootstrap ($TODAY)

**Status global**: ⏳ inicial · path: $PATH_TYPE

| # | Feature | Estado | Detalle |
|---|---------|--------|---------|
| 1 | AI Agent Harness instalado | ✅ | $((${#BASE_DOCS[@]} + ${#EXTRA_DOCS[@]} + 1)) docs (path: $PATH_TYPE) |
| 2 | ADR-001 (path de infra) | ⚠️ stub | Pendiente: completar alternatives + consequences |

---

## Features planeadas (v1)

${A[P6]:-(por definir con tu agente AI)}
EOF

# ─── Agent config file (CLAUDE.md / .cursorrules / etc.) ──────────
if [[ "${A[P18]:-1}" != "3" ]]; then
  AGENT_KEY="${A[P9]:-1}"
  case "$AGENT_KEY" in
    1|2) AGENT_FILE="CLAUDE.md" ;;
    3)   AGENT_FILE=".cursorrules" ;;
    4)   AGENT_FILE=".clinerules" ;;
    5)   AGENT_FILE="agent.md" ;;
    6)   AGENT_FILE=".aider.conf.yml" ;;
    7)   AGENT_FILE=".continue/config.json" ;;
    *)   AGENT_FILE="CLAUDE.md" ;;
  esac

  if [[ "${A[P18]:-1}" == "1" ]]; then
    # Con contenido
    if [[ "$AGENT_FILE" == ".aider.conf.yml" ]]; then
      cat > "$(pwd)/$AGENT_FILE" << EOF
read:
  - docs/README.md
  - docs/active-context.md
  - docs/product-context.md
  - docs/known-issues.md
  - docs/progress.md
EOF
    elif [[ "$AGENT_FILE" == ".continue/config.json" ]]; then
      mkdir -p "$(pwd)/.continue"
      cat > "$(pwd)/$AGENT_FILE" << EOF
{
  "contextProviders": [
    { "name": "folder", "params": { "folders": ["docs"] } }
  ]
}
EOF
    else
      cat > "$(pwd)/$AGENT_FILE" << EOF
# Contexto del Proyecto — $PROJECT_NAME

Este proyecto usa el AI Agent Harness Template. Al inicio de cada sesión:

1. Lee \`docs/README.md\` para entender la estructura
2. Lee estos 4 docs prioritarios (te dan 80% del contexto):
   - \`docs/active-context.md\` — qué pasó la última sesión
   - \`docs/product-context.md\` — qué es este proyecto
   - \`docs/progress.md\` — qué features funcionan ya
   - \`docs/known-issues.md\` — qué bugs conocidos hay
3. Según la tarea, lee también:
   - Técnico: \`tech-context.md\`, \`system-patterns.md\`, \`decisions.md\`
EOF
      if [[ "$PATH_TYPE" == "vps" ]]; then
        cat >> "$(pwd)/$AGENT_FILE" << EOF
   - Emergencias: \`runbook.md\`, \`disaster-recovery.md\`, \`monitoring.md\`
   - Costos / capacity planning: \`costs.md\`, \`infrastructure.md\`
EOF
      elif [[ "$PATH_TYPE" == "vercel" ]]; then
        cat >> "$(pwd)/$AGENT_FILE" << EOF
   - Deploy / costos: \`deploy-to-vercel.md\`, \`cloud-services-costs.md\`
EOF
      else
        cat >> "$(pwd)/$AGENT_FILE" << EOF
   - Setup: \`local-setup.md\`
EOF
      fi
      cat >> "$(pwd)/$AGENT_FILE" << EOF

## Path de infraestructura: \`$PATH_TYPE\`

EOF
      case "$PATH_TYPE" in
        local)  echo "App vive en localhost — desarrollo local solamente." >> "$(pwd)/$AGENT_FILE" ;;
        vercel) echo "App deployada en Vercel + Supabase/Clerk managed." >> "$(pwd)/$AGENT_FILE" ;;
        vps)    echo "Self-hosted en VPS Contabo + Docker Swarm (patrón Publiafy)." >> "$(pwd)/$AGENT_FILE" ;;
      esac
      cat >> "$(pwd)/$AGENT_FILE" << EOF

## Reglas para mantener los docs vivos

- Al final de cada sesión productiva: actualizá \`active-context.md\` (entry nueva al tope) y \`progress.md\`
- Si encontrás un bug → agregá entrada en \`known-issues.md\`
- Si un bug se repite 2da vez → lección en \`lessons-learned.md\`
- Si tomamos una decisión arquitectónica → nuevo ADR en \`decisions.md\`

## 🔌 Plugins recomendados (correr 1 sola vez en Claude Code)

\`\`\`
/plugin install superpowers@claude-plugins-official
/plugin install frontend-design@claude-plugins-official
/reload-plugins
\`\`\`

| Plugin | Stars | Qué hace |
|---|---|---|
| **Superpowers** (obra/superpowers) | 219k⭐ MIT | Skills framework + metodología TDD + spec-driven coding |
| **Frontend Design** (Anthropic oficial) | — | UI con dirección estética coherente (brutalist/maximalist/etc.) |
| **Context7** (upstash) | — | Docs de libs siempre actualizadas |
| **UI/UX Pro Max** | 87.8k⭐ MIT | Design system generator — install: \`npm i -g uipro-cli && uipro init --ai claude\` |
| **claude-mem** | — | Persistencia de contexto entre sesiones (complementa este harness) |

Más recursos: https://github.com/hesreallyhim/awesome-claude-code (45.8k⭐)
EOF
    fi
    echo "${DIM}✓ Creado $AGENT_FILE con instrucciones para tu agente${RESET}"
  else
    touch "$(pwd)/$AGENT_FILE"
    echo "${DIM}✓ Creado $AGENT_FILE vacío${RESET}"
  fi
fi

# ─── Generar install-plugins.sh si el user pidió plugins ────────
if [[ "${A[P9P]:-3}" == "1" || "${A[P9P]:-3}" == "2" ]]; then
  cat > "$(pwd)/install-plugins.sh" << 'SCRIPT_EOF'
#!/usr/bin/env bash
# install-plugins.sh — Plugins recomendados para Claude Code
#
# Ejecutar UNA sola vez después de instalar Claude Code.
# Algunos requieren slash commands DENTRO de Claude Code (no en bash).

set -e

cat <<INSTRUCTIONS
🔌 Instalación de plugins recomendados

PARTE 1 — UI/UX Pro Max (vía npm, corre AHORA):
INSTRUCTIONS

# UI/UX Pro Max (npm-based)
npm install -g uipro-cli 2>/dev/null || sudo npm install -g uipro-cli
uipro init --ai claude

cat <<INSTRUCTIONS

✅ UI/UX Pro Max instalado.

PARTE 2 — Plugins en Claude Code (slash commands):

Abrí Claude Code (claude en terminal) y pegá ESTOS comandos uno por uno:

  /plugin install superpowers@claude-plugins-official
  /plugin install frontend-design@claude-plugins-official
  /plugin install context7@upstash
INSTRUCTIONS

SCRIPT_EOF
  # Si eligió "full vibecoding", agregar más
  if [[ "${A[P9P]}" == "2" ]]; then
    cat >> "$(pwd)/install-plugins.sh" << 'SCRIPT_EOF'

cat <<INSTRUCTIONS

PARTE 3 — Full vibecoding (session continuity):

  /plugin install claude-mem
INSTRUCTIONS

SCRIPT_EOF
  fi

  cat >> "$(pwd)/install-plugins.sh" << 'SCRIPT_EOF'

cat <<INSTRUCTIONS

PARTE 4 — Recargar:

  /reload-plugins

✅ Listo. Más recursos: https://github.com/hesreallyhim/awesome-claude-code
INSTRUCTIONS
SCRIPT_EOF
  chmod +x "$(pwd)/install-plugins.sh"
  echo "${DIM}✓ Creado install-plugins.sh (correlo cuando configures Claude Code)${RESET}"
fi

# ─── Git init ────────────────────────────────────────────────────
if [[ "${A[P17]:-1}" == "1" ]]; then
  if [[ ! -d "$(pwd)/.git" ]]; then
    echo "${DIM}🔧 git init...${RESET}"
    git init -q
    # .gitignore básico
    [[ ! -f .gitignore ]] && cat > .gitignore << 'EOF'
node_modules/
.env
.env.local
.env.production
*.log
.DS_Store
dist/
build/
.next/
local.db
*.sqlite
EOF
    git add docs/ 2>/dev/null || true
    [[ -f .gitignore ]] && git add .gitignore
    [[ -f ".env.example" ]] && git add .env.example
    [[ -f "docker-stack.yml" ]] && git add docker-stack.yml
    [[ -f "Dockerfile" ]] && git add Dockerfile
    [[ -f "vercel.json" ]] && git add vercel.json
    [[ -f "CLAUDE.md" ]] && git add CLAUDE.md
    [[ -f ".cursorrules" ]] && git add .cursorrules
    [[ -f ".clinerules" ]] && git add .clinerules
    [[ -f "agent.md" ]] && git add agent.md
    git commit -q -m "chore: bootstrap AI Agent Harness (path: $PATH_TYPE)" 2>/dev/null || true
    echo "${DIM}✓ Initial commit creado${RESET}"
  fi
fi

# ═══════════════════════════════════════════════════════════════════
#  FIN — Próximos pasos
# ═══════════════════════════════════════════════════════════════════
echo ""
echo "${BOLD}${GREEN}✅ Harness instalado — path: $PATH_TYPE${RESET}"
echo ""
echo "${BOLD}📋 Próximos pasos:${RESET}"
echo ""

case "$PATH_TYPE" in
  local)
    cat << EOF
  ${YELLOW}1.${RESET} Copiá .env.example a .env y editá los valores
  ${YELLOW}2.${RESET} Decidí stack con tu agente AI: leelo todo en docs/ y preguntale
     "Lee docs/product-context.md y sugiéreme un stack para esto"
  ${YELLOW}3.${RESET} Empezá a codear localmente con \`npm run dev\` o equivalente
  ${YELLOW}4.${RESET} Para compartir con alguien: ver docs/local-setup.md (ngrok/Tailscale)
EOF
    ;;
  vercel)
    cat << EOF
  ${YELLOW}1.${RESET} Crear cuentas: vercel.com, supabase.com, clerk.com (todas gratis)
  ${YELLOW}2.${RESET} Push a GitHub: \`gh repo create $PROJECT_NAME --public --source=. --push\`
  ${YELLOW}3.${RESET} En vercel.com → New Project → import tu repo
  ${YELLOW}4.${RESET} Agregar env vars en Vercel Settings (lista en .env.example)
  ${YELLOW}5.${RESET} Ver docs/deploy-to-vercel.md para guía paso-a-paso

  ${BLUE}💡 Recordá: este path escala caro. Ver docs/cloud-services-costs.md${RESET}
EOF
    ;;
  vps)
    cat << EOF
  ${YELLOW}1.${RESET} Contratar VPS Contabo (${A[P4C_LABEL]:-Cloud VPS 10 \$5/mes})
  ${YELLOW}2.${RESET} En el VPS:
        - Instalar Docker + iniciar Swarm: \`docker swarm init\`
        - Subir tu código (git clone o scp)
        - Editar .env con valores reales
        - Crear red Docker: \`docker network create -d overlay --attachable $(echo $PROJECT_NAME | tr '[:upper:]' '[:lower:]')_net\`
  ${YELLOW}3.${RESET} Cargar secrets: \`bash setup-secrets.sh\`
  ${YELLOW}4.${RESET} Configurar DNS: A record de tu dominio → IP del VPS
  ${YELLOW}5.${RESET} Build + deploy:
        - \`docker build -t $PROJECT_NAME:latest .\`
        - \`docker stack deploy -c docker-stack.yml $PROJECT_NAME\`
  ${YELLOW}6.${RESET} Verificar: \`curl https://tu-dominio.com/api/health\` → 200
  ${YELLOW}7.${RESET} Setup backups cron: ver docs/disaster-recovery.md
  ${YELLOW}8.${RESET} Monitoring: configurar UptimeRobot (5 min, gratis)

  ${BLUE}💡 Tu agente AI tiene el contexto completo en docs/ + configs.${RESET}
EOF
    ;;
esac

echo ""
echo "${BOLD}🤖 Para tu agente AI ($AGENT_FILE creado):${RESET}"
echo "${DIM}Abrí $AGENT_FILE — ya tiene las instrucciones de qué leer al iniciar sesión.${RESET}"
echo ""
echo "${BOLD}${MAGENTA}═══════════════════════════════════════════════════════════${RESET}"
echo "${BOLD}${MAGENTA}  Listo. Empezá a construir 🚀${RESET}"
echo "${BOLD}${MAGENTA}═══════════════════════════════════════════════════════════${RESET}"
echo ""
