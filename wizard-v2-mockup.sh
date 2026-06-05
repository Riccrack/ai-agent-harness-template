#!/usr/bin/env bash
# wizard-v2-mockup.sh — DRY-RUN del wizard v2.
#
# Esto es un MOCKUP para validar UX antes de implementar el wizard real.
# - Muestra TODAS las preguntas en su orden definitivo
# - Acepta tus inputs (para que veas cómo se siente la conversación)
# - NO crea archivos, NO toca git, NO ejecuta nada destructivo
# - Al final imprime un resumen de "esto sería lo que habría pasado"
#
# Las secciones marcadas con [PENDING ROUND 2] tienen contenido placeholder
# que se va a llenar con los repos validados por la 2da ronda de research.
#
# Uso: bash wizard-v2-mockup.sh
#
# Modos disponibles:
#   bash wizard-v2-mockup.sh           # interactivo full (18 preguntas)
#   bash wizard-v2-mockup.sh --quick   # solo 5 esenciales
#   bash wizard-v2-mockup.sh --deep    # full + 8 edge cases extra

set -uo pipefail

# ─── Colors ────────────────────────────────────────────────────
if [[ -t 1 ]] && command -v tput >/dev/null 2>&1; then
  BOLD=$(tput bold); DIM=$(tput dim)
  GREEN=$(tput setaf 2); YELLOW=$(tput setaf 3)
  BLUE=$(tput setaf 4); CYAN=$(tput setaf 6); MAGENTA=$(tput setaf 5)
  RED=$(tput setaf 1); RESET=$(tput sgr0)
else
  BOLD="" DIM="" GREEN="" YELLOW="" BLUE="" CYAN="" MAGENTA="" RED="" RESET=""
fi

# ─── State ─────────────────────────────────────────────────────
MODE="standard"
[[ "${1:-}" == "--quick" ]] && MODE="quick"
[[ "${1:-}" == "--deep"  ]] && MODE="deep"

declare -A ANSWERS

# ─── Helpers ───────────────────────────────────────────────────

# heading "🌟 Etapa 1 — Sobre tu app"
heading() {
  echo ""
  echo "${BOLD}${MAGENTA}═══════════════════════════════════════════════════════════${RESET}"
  echo "${BOLD}${MAGENTA}  $1${RESET}"
  echo "${BOLD}${MAGENTA}═══════════════════════════════════════════════════════════${RESET}"
  echo ""
}

# ask_text PX "Pregunta" "default" → ANSWERS[PX]=valor
ask_text() {
  local key="$1" prompt="$2" default="${3:-}"
  echo "${BOLD}${CYAN}? ${prompt}${RESET}"
  [[ -n "$default" ]] && echo "${DIM}  (default: $default — Enter para usarlo)${RESET}"
  read -r -p "${CYAN}  > ${RESET}" val
  ANSWERS[$key]="${val:-$default}"
  echo ""
}

# ask_multiline PX "Pregunta" → ANSWERS[PX]=valor multilinea
ask_multiline() {
  local key="$1" prompt="$2"
  echo "${BOLD}${CYAN}? ${prompt}${RESET}"
  echo "${DIM}  (escribí varias líneas si querés; cuando termines, una línea vacía + Enter)${RESET}"
  local lines="" line
  while IFS= read -r -p "${CYAN}  > ${RESET}" line; do
    [[ -z "$line" ]] && break
    lines="${lines}${line}"$'\n'
  done
  ANSWERS[$key]="$lines"
  echo ""
}

# ask_choice PX "Pregunta" "opt1" "opt2" ... → ANSWERS[PX]=índice
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
  ANSWERS[$key]="$choice|${options[$((choice-1))]}"
  echo ""
}

# ask_choice_with_help — igual que ask_choice pero permite "?" para más info
ask_choice_with_help() {
  local key="$1" prompt="$2" help_text="$3"
  shift 3
  local options=("$@")
  while true; do
    echo "${BOLD}${CYAN}? ${prompt}${RESET}"
    echo "${DIM}  (escribí '?' si querés que te explique las opciones)${RESET}"
    local i=1
    for opt in "${options[@]}"; do
      echo "  ${BOLD}$i)${RESET} $opt"
      ((i++))
    done
    local choice
    read -r -p "${CYAN}  Opción [1-${#options[@]}] o '?': ${RESET}" choice
    if [[ "$choice" == "?" ]]; then
      echo ""
      echo "${YELLOW}─── Ayuda ───${RESET}"
      echo "$help_text"
      echo ""
      continue
    fi
    choice=${choice:-1}
    ANSWERS[$key]="$choice|${options[$((choice-1))]}"
    echo ""
    return
  done
}

# ask_multi PX "Pregunta" "opt1" "opt2" ... → ANSWERS[PX]="1,3,5"
ask_multi() {
  local key="$1" prompt="$2"
  shift 2
  local options=("$@")
  echo "${BOLD}${CYAN}? ${prompt}${RESET}"
  echo "${DIM}  (podés marcar varias separadas por coma, ej: 1,3,5)${RESET}"
  local i=1
  for opt in "${options[@]}"; do
    echo "  ${BOLD}$i)${RESET} $opt"
    ((i++))
  done
  local choice
  read -r -p "${CYAN}  Tus opciones: ${RESET}" choice
  ANSWERS[$key]="${choice:-none}"
  echo ""
}

# ─── Intro ─────────────────────────────────────────────────────
clear 2>/dev/null || true
cat << EOF
${BOLD}${BLUE}🤖 AI Agent Harness — Wizard v2 (DRY-RUN MOCKUP)${RESET}
${DIM}   18 preguntas para preparar tu proyecto antes de empezar a codear con IA.${RESET}

${YELLOW}⚠️  Este es un mockup — NO va a crear archivos, NO va a tocar git.${RESET}
${YELLOW}    Solo te muestra cómo se sentiría el wizard real.${RESET}

Modo actual: ${BOLD}${GREEN}${MODE}${RESET}
  • quick     → 5 preguntas (2 min)  — solo lo esencial
  • standard  → 18 preguntas (8 min) — recomendado
  • deep      → 26 preguntas (20 min) — con edge cases

${DIM}Tips durante el wizard:${RESET}
  ${DIM}• Si no sabés una respuesta, escribí 'no sé' — yo te ayudo después${RESET}
  ${DIM}• Si querés ayuda sobre una pregunta, escribí '?'${RESET}
  ${DIM}• Ctrl+C cancela en cualquier momento${RESET}

EOF
read -r -p "${CYAN}¿Empezamos? [Enter para continuar]${RESET} "

# ═══════════════════════════════════════════════════════════════
# 🌟 ETAPA 1 — Sobre tu app
# ═══════════════════════════════════════════════════════════════
heading "🌟 Etapa 1 — Sobre tu app (5 preguntas)"

# P1
ask_text P1_NAME "P1. ¿Cómo se va a llamar tu proyecto?" "MiApp"

# P2 — la KILLER question
echo "${BOLD}${YELLOW}💡 La siguiente pregunta es la MÁS importante del wizard.${RESET}"
echo "${DIM}   Lo que escribas acá va a ser el contexto principal de tu agente AI."
echo "   No te preocupes por formato — escribí como hablás.${RESET}"
echo ""
ask_multiline P2_DESCRIPTION "P2. Describí tu app en 2-3 oraciones (qué hace y por qué importa)"

# P3 — DISPOSITIVO (la crítica que faltaba)
ask_choice_with_help P3_PLATFORM "P3. ¿En qué dispositivos van a usar tu app?" "
  🌐 Web: lo más simple. Funciona en cualquier navegador (PC + móvil).
       Sin tiendas de apps. Ideal para SaaS, e-commerce, dashboards.

  📱 App móvil nativa: se instala desde Play Store / App Store.
       Costo Apple: \$99/año. Costo Google: \$25 una vez.
       Apple revisa cada update (1-3 días).

  🎯 Web + móvil (PWA o híbrida): una codebase, dos plataformas.
       Más rápido y barato que app nativa pura. iOS limita algunas features.

  💻 Escritorio: programa instalable (Windows/Mac/Linux).
       Tauri (liviano, ~5MB) o Electron (mainstream, ~50MB).

  🤖 Bot: sin pantalla, conversacional vía Telegram/Discord/WhatsApp.
       Stack: Node.js + lib específica (Telegraf/discord.js/Baileys).

  🔌 Solo API: otros developers la consumen. Sin UI.
       Stack: Hono, Fastify, NestJS.

  🧩 Extensión de browser: agrega features a Chrome/Firefox.
       Distribución: Chrome Web Store (\$5 una vez) o Firefox Add-ons (free).
" \
  "🌐 Web (navegador)" \
  "📱 App móvil nativa (Android + iOS)" \
  "📱 Solo Android" \
  "🍎 Solo iOS" \
  "💻 Escritorio (Windows/Mac/Linux)" \
  "🎯 Web + móvil (lo mejor de ambos)" \
  "🤖 Bot (sin interfaz visual)" \
  "🔌 Solo API (sin frontend)" \
  "🧩 Extensión de navegador" \
  "🤔 No estoy seguro / decidan ustedes"

# P4 — para qué
ask_choice P4_PURPOSE "P4. ¿Para qué es esta app?" \
  "Mi negocio (uso interno o herramienta propia)" \
  "Para vender (SaaS público, app comercial)" \
  "Para clientes específicos (consultoría, contrato)" \
  "Personal / hobby (sin fines comerciales)" \
  "Educativo (aprender, portfolio)" \
  "Otro / aún no lo decidí"

# P5 — audiencia
ask_text P5_AUDIENCE "P5. ¿Quiénes la van a usar?" "no sé todavía"

if [[ "$MODE" == "quick" ]]; then
  echo "${GREEN}✓ Modo quick — saltando preguntas opcionales.${RESET}"
else

  # ═══════════════════════════════════════════════════════════════
  # 🎯 ETAPA 2 — Features v1
  # ═══════════════════════════════════════════════════════════════
  heading "🎯 Etapa 2 — Qué va a hacer tu app (2 preguntas)"

  # P6
  ask_multiline P6_FEATURES "P6. Listá las 3 features más importantes para v1 (una por línea)"

  # P7 — datos sensibles
  ask_multi P7_SENSITIVE_DATA "P7. ¿Tu app va a manejar alguno de estos datos? (multi-select)" \
    "Datos personales básicos (nombre, email)" \
    "Pagos / tarjetas de crédito" \
    "Datos médicos / salud" \
    "Datos de menores de 18 años" \
    "Datos financieros / bancarios" \
    "Solo datos públicos / sin datos personales" \
    "No sé todavía"

  # ═══════════════════════════════════════════════════════════════
  # 👤 ETAPA 3 — Sobre vos
  # ═══════════════════════════════════════════════════════════════
  heading "👤 Etapa 3 — Sobre vos (3 preguntas)"

  # P8 — nivel
  ask_choice P8_SKILL "P8. ¿Cuál es tu nivel programando?" \
    "Nunca programé — la IA es mi compañera" \
    "Aprendiendo — sé lo básico" \
    "Junior/Intermedio (1-3 años)" \
    "Senior (3+ años)" \
    "Prefiero no decir"

  # P9 — agente AI
  ask_choice P9_AGENT "P9. ¿Con qué agente AI vas a trabajar? (te creo el archivo de config solo)" \
    "Claude Code (terminal o VS Code)" \
    "Claude Code Desktop (app Mac/Windows)" \
    "Cursor" \
    "Cline (extensión VS Code)" \
    "Antigravity (Google)" \
    "Aider (terminal)" \
    "Continue.dev" \
    "Varios / aún no decido"

  # P10 — país
  ask_choice P10_COUNTRY "P10. ¿En qué país opera principalmente tu app?" \
    "Argentina" \
    "México" \
    "España" \
    "Colombia" \
    "Chile" \
    "Otro LATAM" \
    "USA / Canada" \
    "Europa (no España)" \
    "Global / múltiples países"

  # ═══════════════════════════════════════════════════════════════
  # 🛠️ ETAPA 4 — Stack + Starter recomendado
  # ═══════════════════════════════════════════════════════════════
  heading "🛠️ Etapa 4 — El stack técnico (3 preguntas)"

  # P11 — saber stack
  ask_choice P11_STACK_KNOWN "P11. ¿Sabés qué tecnologías vas a usar?" \
    "Sí, ya sé qué stack quiero (te lo digo abajo)" \
    "No, recomendame uno basado en mis respuestas" \
    "Decido más adelante con mi agente AI"

  # P12 — sugerencia de starter
  echo "${BOLD}${YELLOW}🎁 Recomendaciones de starters / boilerplates${RESET}"
  echo "${DIM}   Basado en tu plataforma (P3) y nivel (P8), estos repos te ahorran"
  echo "   horas de setup. Tu agente AI los va a operar por vos.${RESET}"
  echo ""
  echo "${YELLOW}⚠️  Importante: NINGÚN starter es 'no-code' — todos asumen Node.js"
  echo "    + Git instalados. Tu agente AI va a hacer el resto.${RESET}"
  echo ""

  # [PENDING ROUND 2] — Las opciones que aparecen acá DEPENDEN de P3.
  # Esto es solo un placeholder para que veas el flow.
  case "${ANSWERS[P3_PLATFORM]}" in
    1\|*|6\|*)
      # Web o web+mobile
      ask_choice P12_STARTER "P12. Elegí un starter:" \
        "ixartz/SaaS-Boilerplate (GRATIS, MIT, 7.2k⭐) — Next.js+Clerk+Drizzle con AGENTS.md" \
        "Kiranism/next-shadcn-dashboard-starter (GRATIS, MIT, 6.5k⭐) — Dashboard B2B" \
        "vercel/commerce (GRATIS, MIT) — E-commerce Next.js+Shopify" \
        "onwidget/astrowind (GRATIS, MIT) — Landing+blog Astro" \
        "Supastarter (PAGO \$349) — Vibecoding-first con AGENTS.md+claude.md" \
        "📚 Quiero ver más detalle de cada uno" \
        "🤔 No conozco ninguna — preguntale a mi agente AI" \
        "⏭️  Empiezo de cero sin template"
      ;;
    2\|*|3\|*|4\|*)
      # Mobile
      echo "${RED}[PENDING ROUND 2] — Recomendaciones mobile (Expo/Ignite/Flutter) están siendo investigadas.${RESET}"
      ask_choice P12_STARTER "P12. Elegí un starter:" \
        "[Pendiente verificar] ixartz/React-Native-Boilerplate" \
        "[Pendiente verificar] Ignite (Infinite Red)" \
        "[Pendiente verificar] Expo router templates" \
        "📚 Más detalle" \
        "🤔 Preguntale a mi agente AI" \
        "⏭️  Empiezo de cero"
      ;;
    7\|*)
      # Bot
      echo "${RED}[PENDING ROUND 2] — Recomendaciones bot (Telegram/Discord/WhatsApp) están siendo investigadas.${RESET}"
      ask_choice P12_STARTER "P12. Elegí un starter:" \
        "[Pendiente verificar] bot-base/telegram-bot-template" \
        "[Pendiente verificar] discord.js boilerplate" \
        "[Pendiente verificar] WhatsApp con Baileys (⚠️ riesgo de ban)" \
        "📚 Más detalle" \
        "🤔 Preguntale a mi agente AI" \
        "⏭️  Empiezo de cero"
      ;;
    *)
      echo "${RED}[PENDING ROUND 2] — Recomendaciones para este tipo de app están siendo investigadas.${RESET}"
      ANSWERS[P12_STARTER]="pendiente"
      ;;
  esac

  # P13 — hosting
  ask_choice P13_HOSTING "P13. ¿Dónde la vas a hospedar?" \
    "No sé / recomendame uno (free tier sugerido por defecto)" \
    "Vercel (free tier generoso, ideal Next.js)" \
    "Netlify (free tier, ideal Astro/static)" \
    "Cloudflare Pages / Workers (gratis hasta 100k req/día)" \
    "Railway / Fly.io (paid, ideal apps con backend)" \
    "VPS propio (Contabo, Hetzner, DigitalOcean)" \
    "AWS / GCP / Azure" \
    "Solo localhost por ahora"

  # ═══════════════════════════════════════════════════════════════
  # 💰 ETAPA 5 — Monetización (skip si P4 ≠ vender)
  # ═══════════════════════════════════════════════════════════════
  if [[ "${ANSWERS[P4_PURPOSE]}" == "2"* ]] || [[ "${ANSWERS[P4_PURPOSE]}" == "3"* ]]; then
    heading "💰 Etapa 5 — Monetización (3 preguntas)"

    ask_choice P14_BILLING "P14. ¿Cómo vas a cobrar?" \
      "Gratis (sin monetización todavía)" \
      "Pago único (compra y listo)" \
      "Suscripción mensual" \
      "Suscripción anual" \
      "Freemium (gratis + features pagas)" \
      "No sé todavía"

    ask_choice P15_PROCESSOR "P15. ¿Procesador de pagos?" \
      "No sé / recomendame" \
      "Stripe (global, USA-friendly)" \
      "Mercado Pago (LATAM)" \
      "PayPal" \
      "Lemon Squeezy (Merchant of Record, sin lidiar con impuestos)" \
      "Polar (open source)" \
      "Otro"

    ask_choice P16_CURRENCY "P16. ¿En qué moneda?" \
      "USD" \
      "MXN" \
      "ARS" \
      "EUR" \
      "Múltiples (multi-currency)"
  else
    echo "${DIM}⏭️  Saltando Etapa 5 (Monetización) — no aplica según P4.${RESET}"
    echo ""
  fi

fi # fin de modo no-quick

# ═══════════════════════════════════════════════════════════════
# 🔍 ETAPA EXTRA — Solo en modo DEEP
# ═══════════════════════════════════════════════════════════════
if [[ "$MODE" == "deep" ]]; then
  heading "🔍 Etapa Deep — Edge cases avanzados (8 preguntas)"

  ask_choice D1_I18N "D1. ¿Vas a necesitar múltiples idiomas?" \
    "No, solo un idioma" \
    "Sí, desde día 1" \
    "Quizás más adelante"

  ask_choice D2_MULTITENANT "D2. ¿Multi-tenant? (cada cliente con sus datos separados)" \
    "No" "Sí" "No estoy seguro qué significa"

  ask_choice D3_REALTIME "D3. ¿Necesita features en tiempo real? (chat live, notificaciones push, sync entre users)" \
    "No" "Sí" "No estoy seguro"

  ask_choice D4_FILES "D4. ¿Los usuarios suben archivos pesados (videos, PDFs grandes)?" \
    "No" "Sí, pocos archivos chicos (<5MB)" "Sí, muchos / pesados (>10MB)"

  ask_choice D5_EMAIL "D5. ¿Vas a mandar emails (welcome, password reset, notificaciones)?" \
    "No" "Sí (recomiendo Resend por simplicidad)" "Sí, en volumen alto"

  ask_choice D6_AI "D6. ¿La app usa IA generativa internamente?" \
    "No" \
    "Sí, chat con LLM" \
    "Sí, RAG (chat con mis docs)" \
    "Sí, agentes con tools/function-calling" \
    "Sí, generación de imágenes/video"

  ask_choice D7_TESTING "D7. ¿Qué nivel de testing automático querés?" \
    "Ninguno (manual solo)" \
    "Tests unitarios básicos" \
    "Tests unitarios + integración" \
    "Suite completa con E2E"

  ask_choice D8_MONITORING "D8. ¿Querés monitoreo de errores en producción desde día 1?" \
    "No, después veré" \
    "Sí, Sentry (más popular)" \
    "Sí, alternativa open source"
fi

# ═══════════════════════════════════════════════════════════════
# ⚙️ ETAPA 6 — Setup técnico
# ═══════════════════════════════════════════════════════════════
heading "⚙️ Etapa 6 — Setup técnico final (2 preguntas)"

ask_choice P17_GIT "P17. ¿Inicializar repositorio git automáticamente?" \
  "Sí, hacé git init y primer commit" \
  "Ya tengo git inicializado en este folder" \
  "No, prefiero hacerlo a mano"

ask_choice P18_AGENT_FILE "P18. ¿Querés que cree el archivo de config de tu agente AI (CLAUDE.md/.cursorrules/etc.)?" \
  "Sí, con instrucciones para leer docs/ al iniciar sesión" \
  "Sí pero dejá el contenido vacío para llenarlo yo" \
  "No, lo hago a mano"

# ═══════════════════════════════════════════════════════════════
# 📋 RESUMEN FINAL
# ═══════════════════════════════════════════════════════════════
heading "📋 Resumen — esto es lo que el wizard real haría"

cat << EOF
${BOLD}Tu proyecto:${RESET}
  Nombre:        ${ANSWERS[P1_NAME]}
  Descripción:   $(echo "${ANSWERS[P2_DESCRIPTION]}" | head -1)...
  Plataforma:    ${ANSWERS[P3_PLATFORM]##*|}
  Propósito:     ${ANSWERS[P4_PURPOSE]##*|}
  Audiencia:     ${ANSWERS[P5_AUDIENCE]:-(no respondida)}

EOF

if [[ "$MODE" != "quick" ]]; then
  cat << EOF
${BOLD}Features v1:${RESET}
$(echo "${ANSWERS[P6_FEATURES]:-(no respondidas)}" | sed 's/^/  • /')

${BOLD}Tu perfil:${RESET}
  Nivel:         ${ANSWERS[P8_SKILL]##*|}
  Agente AI:     ${ANSWERS[P9_AGENT]##*|}
  País:          ${ANSWERS[P10_COUNTRY]##*|}

${BOLD}Stack y hosting:${RESET}
  Decisión:      ${ANSWERS[P11_STACK_KNOWN]##*|}
  Starter:       ${ANSWERS[P12_STARTER]:-(no elegido)}
  Hosting:       ${ANSWERS[P13_HOSTING]##*|}
EOF
fi

if [[ -n "${ANSWERS[P14_BILLING]:-}" ]]; then
  cat << EOF

${BOLD}Monetización:${RESET}
  Modelo:        ${ANSWERS[P14_BILLING]##*|}
  Procesador:    ${ANSWERS[P15_PROCESSOR]##*|}
  Moneda:        ${ANSWERS[P16_CURRENCY]##*|}
EOF
fi

cat << EOF

${BOLD}Setup:${RESET}
  Git:           ${ANSWERS[P17_GIT]##*|}
  Config agente: ${ANSWERS[P18_AGENT_FILE]##*|}

${BOLD}${GREEN}─── Si esto fuera real, ahora pasaría: ───${RESET}

  1. Crear ./docs/ con los 13 archivos del harness
  2. Reemplazar placeholders ({{PROJECT_NAME}}, {{YYYY-MM-DD}}, {{OWNER}})
  3. Pre-llenar product-context.md con tu descripción (P2)
  4. Pre-llenar tech-context.md con tu stack/hosting
  5. Pre-llenar pendientes.md con tus 3 features (P6)
  6. Pre-llenar decisions.md ADR-001 con la decisión de stack
  7. Pre-llenar security.md según datos sensibles (P7)
  8. Crear ${ANSWERS[P9_AGENT]##*|}.md/rules en raíz del proyecto
  9. Si elegiste starter: clonar ese repo en ./starter-template/
 10. Si elegiste git init: \`git init\` + commit inicial

${BOLD}${YELLOW}─── Pendientes para tu agente AI: ───${RESET}

EOF

# Detectar "no sé" en las respuestas
todos=()
[[ "${ANSWERS[P5_AUDIENCE]}" == "no sé"* ]] && todos+=("Definir audiencia detallada")
[[ "${ANSWERS[P11_STACK_KNOWN]}" == "3"* ]] && todos+=("Decidir stack técnico con tu agente AI")
[[ "${ANSWERS[P13_HOSTING]}" == "1"* ]] && todos+=("Elegir hosting tras estimar carga")
[[ "${ANSWERS[P12_STARTER]:-}" == *"preguntale"* ]] && todos+=("Discutir qué starter usar con tu agente")

if [[ ${#todos[@]} -gt 0 ]]; then
  for t in "${todos[@]}"; do
    echo "  ☐ $t"
  done
  echo ""
  echo "${DIM}  Estos quedarían en docs/pendientes-decisiones.md con un prompt sugerido${RESET}"
  echo "${DIM}  para que tu agente AI te ayude a definirlos.${RESET}"
else
  echo "  ✅ Cubriste todo — listo para empezar a codear con tu agente AI."
fi

echo ""
echo "${BOLD}${BLUE}═══════════════════════════════════════════════════════════${RESET}"
echo "${BOLD}${BLUE}  Fin del mockup — ningún archivo fue creado.${RESET}"
echo "${BOLD}${BLUE}═══════════════════════════════════════════════════════════${RESET}"
echo ""
echo "${DIM}¿Qué te pareció el flow? Decime:${RESET}"
echo "${DIM}  • ¿Alguna pregunta que sobra o que falta?${RESET}"
echo "${DIM}  • ¿Algún wording confuso?${RESET}"
echo "${DIM}  • ¿Las opciones de cada pregunta cubren bien tu caso?${RESET}"
echo ""
