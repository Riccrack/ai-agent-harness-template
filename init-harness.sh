#!/usr/bin/env bash
# init-harness.sh — Bootstrap interactivo del AI Agent Harness.
#
# Uso:
#   ./init-harness.sh                           # wizard interactivo
#   ./init-harness.sh "ProjectName"             # con nombre directo
#   OWNER="Tu Nombre" ./init-harness.sh ...     # con owner explícito
#
# Lo que hace:
#   1. Pregunta nombre / stack / idioma / owner (skippable si pasás args)
#   2. Crea `docs/` en el cwd con los 13 skeletons
#   3. Reemplaza placeholders ({{PROJECT_NAME}}, {{YYYY-MM-DD}}, {{OWNER}})
#   4. Pre-fill tech-context.md según el stack elegido
#   5. Genera ADR-001 stub con la decisión de stack
#   6. Crea entrada inicial en active-context.md + progress.md
#   7. Imprime guía de próximos pasos
#
# Requisitos: bash, sed, basic POSIX (Linux/macOS/WSL/Git Bash en Windows).

set -euo pipefail

# ─── Colors (opcional, fallback si no soporta) ──────────────────
if [[ -t 1 ]] && command -v tput >/dev/null 2>&1; then
  BOLD=$(tput bold)
  DIM=$(tput dim)
  GREEN=$(tput setaf 2)
  YELLOW=$(tput setaf 3)
  BLUE=$(tput setaf 4)
  CYAN=$(tput setaf 6)
  RESET=$(tput sgr0)
else
  BOLD="" DIM="" GREEN="" YELLOW="" BLUE="" CYAN="" RESET=""
fi

# ─── Helpers ────────────────────────────────────────────────────
ask() {
  local prompt="$1"
  local default="${2:-}"
  local var
  if [[ -n "$default" ]]; then
    read -r -p "${CYAN}? ${prompt} ${DIM}[$default]${RESET} " var || true
    echo "${var:-$default}"
  else
    read -r -p "${CYAN}? ${prompt}${RESET} " var || true
    echo "$var"
  fi
}

ask_choice() {
  local prompt="$1"
  shift
  local options=("$@")
  echo "${CYAN}? ${prompt}${RESET}" >&2
  local i=1
  for opt in "${options[@]}"; do
    echo "  ${BOLD}$i)${RESET} $opt" >&2
    ((i++))
  done
  local choice
  read -r -p "${CYAN}  Opción [1-${#options[@]}]:${RESET} " choice || true
  choice=${choice:-1}
  echo "${options[$((choice-1))]}"
}

# ─── Detectar ubicación del script + skeleton ───────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKELETON_DIR="$SCRIPT_DIR/harness-skeleton"

if [[ ! -d "$SKELETON_DIR" ]]; then
  echo "${YELLOW}❌ No encontré $SKELETON_DIR${RESET}"
  echo "   Asegurate de correr esto desde el directorio del template."
  exit 1
fi

# ─── Banner ─────────────────────────────────────────────────────
echo ""
echo "${BOLD}${BLUE}🤖 AI Agent Harness — Bootstrap${RESET}"
echo "${DIM}   13 markdown docs that turn your project AI-agent-friendly${RESET}"
echo ""

# ─── Wizard interactivo ─────────────────────────────────────────
PROJECT_NAME="${1:-}"
if [[ -z "$PROJECT_NAME" ]]; then
  PROJECT_NAME=$(ask "Nombre del proyecto" "MiApp")
fi

OWNER="${OWNER:-}"
if [[ -z "$OWNER" ]]; then
  GIT_NAME=$(git config user.name 2>/dev/null || echo "")
  OWNER=$(ask "Owner / autor" "${GIT_NAME:-Anonymous}")
fi

LANG_CONTENT=$(ask_choice "Idioma del contenido de los docs:" "Español" "English" "Português")

STACK=$(ask_choice "Stack principal:" \
  "Node.js (Express / Next.js)" \
  "Python (Django / FastAPI / Flask)" \
  "Ruby (Rails)" \
  "Go" \
  "Rust" \
  "PHP (Laravel)" \
  "Java / Kotlin (Spring)" \
  "Otro / Decido después")

INIT_GIT=$(ask "¿Inicializar git? (y/N)" "n")

echo ""
echo "${BOLD}Resumen:${RESET}"
echo "  Proyecto: ${GREEN}$PROJECT_NAME${RESET}"
echo "  Owner:    ${GREEN}$OWNER${RESET}"
echo "  Idioma:   ${GREEN}$LANG_CONTENT${RESET}"
echo "  Stack:    ${GREEN}$STACK${RESET}"
echo "  Git init: ${GREEN}$INIT_GIT${RESET}"
echo ""
read -r -p "${CYAN}¿Continuar? [Y/n]${RESET} " CONFIRM
CONFIRM=${CONFIRM:-y}
if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
  echo "Cancelado."
  exit 0
fi

# ─── Crear docs/ ────────────────────────────────────────────────
TARGET_DIR="$(pwd)/docs"
if [[ -d "$TARGET_DIR" ]] && ls "$TARGET_DIR"/*.md >/dev/null 2>&1; then
  echo ""
  echo "${YELLOW}⚠️  Ya existen .md en $TARGET_DIR${RESET}"
  read -r -p "${CYAN}¿Sobreescribir? Subdirs como pendientes/ se mantienen [y/N]${RESET} " OVERWRITE
  if [[ ! "${OVERWRITE:-n}" =~ ^[Yy]$ ]]; then
    echo "Cancelado."
    exit 0
  fi
fi
mkdir -p "$TARGET_DIR"

echo ""
echo "${DIM}📋 Copiando 13 docs skeleton...${RESET}"
cp "$SKELETON_DIR"/*.md "$TARGET_DIR/"

# ─── Reemplazar placeholders ────────────────────────────────────
TODAY=$(date -u +%Y-%m-%d)
echo "${DIM}🔧 Reemplazando placeholders...${RESET}"

# Detectar sed flavor
SED_ARGS=(-i)
if [[ "$(uname -s)" == "Darwin" ]]; then
  SED_ARGS=(-i '')
fi

find "$TARGET_DIR" -maxdepth 1 -type f -name '*.md' -exec sed "${SED_ARGS[@]}" \
  -e "s/{{PROJECT_NAME}}/$PROJECT_NAME/g" \
  -e "s/{{YYYY-MM-DD}}/$TODAY/g" \
  -e "s/{{OWNER}}/$OWNER/g" \
  {} \;

# ─── Stack-specific pre-fill en tech-context.md ─────────────────
echo "${DIM}🎨 Pre-fill de tech-context.md según stack '$STACK'...${RESET}"

case "$STACK" in
  "Node.js"*)
    STACK_BACKEND="Node.js + Express"
    STACK_RUNTIME="Node 20+"
    STACK_PKG="npm / pnpm"
    STACK_FW_HINT="Next.js / Express / Fastify"
    ;;
  "Python"*)
    STACK_BACKEND="Python + Django / FastAPI"
    STACK_RUNTIME="Python 3.11+"
    STACK_PKG="pip / poetry / uv"
    STACK_FW_HINT="Django / FastAPI / Flask"
    ;;
  "Ruby"*)
    STACK_BACKEND="Ruby on Rails"
    STACK_RUNTIME="Ruby 3.2+"
    STACK_PKG="bundler"
    STACK_FW_HINT="Rails 7"
    ;;
  "Go"*)
    STACK_BACKEND="Go (net/http o Fiber/Echo)"
    STACK_RUNTIME="Go 1.22+"
    STACK_PKG="go mod"
    STACK_FW_HINT="stdlib / Fiber / Echo / Gin"
    ;;
  "Rust"*)
    STACK_BACKEND="Rust (Axum / Actix)"
    STACK_RUNTIME="Rust stable"
    STACK_PKG="cargo"
    STACK_FW_HINT="Axum / Actix / Rocket"
    ;;
  "PHP"*)
    STACK_BACKEND="PHP + Laravel"
    STACK_RUNTIME="PHP 8.3+"
    STACK_PKG="composer"
    STACK_FW_HINT="Laravel 11"
    ;;
  "Java"*)
    STACK_BACKEND="Java/Kotlin + Spring Boot"
    STACK_RUNTIME="JDK 21+"
    STACK_PKG="Maven / Gradle"
    STACK_FW_HINT="Spring Boot"
    ;;
  *)
    STACK_BACKEND="TBD"
    STACK_RUNTIME="TBD"
    STACK_PKG="TBD"
    STACK_FW_HINT="por decidir"
    ;;
esac

cat > "$TARGET_DIR/tech-context.md" << EOF
# ⚙️ tech-context.md — Stack técnico de $PROJECT_NAME

> **Última actualización**: $TODAY
> **Audiencia**: agentes de IA.
> **Propósito**: catálogo técnico (no patrones — esos van a system-patterns).
> **Cuándo actualizar**: cuando se agregan rutas/servicios/migrations/deps mayores.

---

## Stack principal

| Categoría | Tech |
|-----------|------|
| Backend | $STACK_BACKEND |
| Runtime | $STACK_RUNTIME |
| Package manager | $STACK_PKG |
| Framework | $STACK_FW_HINT |
| Frontend | TBD (React / Vue / Svelte / SSR-only) |
| DB | TBD (PostgreSQL / MySQL / MongoDB / SQLite) |
| Auth | TBD (JWT / Sessions / OAuth / Auth.js) |
| Pagos | TBD (Stripe / Mercado Pago / Paddle / N/A) |
| AI / ML | TBD (OpenAI / Anthropic / Gemini / N/A) |
| Hosting | TBD (Vercel / Fly / Railway / VPS / AWS) |
| Containers | TBD (Docker / N/A) |
| Proxy | TBD (Traefik / Nginx / Caddy / Cloudflare) |

## Estructura de archivos

\`\`\`
$PROJECT_NAME/
├── backend/        # TBD
├── frontend/       # TBD
└── docs/           # AI Agent Harness (este directorio)
\`\`\`

## Rutas backend

(Llenar a medida que se agreguen)

| Prefijo | Archivo | Dominio |
|---------|---------|---------|
| \`/api/...\` | \`routes/X.js\` | ... |

## Servicios backend

(Llenar a medida que se agreguen)

## Páginas frontend

(Llenar a medida que se agreguen)

## Schema de DB

(Llenar a medida que se diseñe)

## Variables de entorno

(Crítico: documentar dónde viven — \`.env\` local / Vault / Portainer / etc. NUNCA committed)

## Deploy

(Llenar cuando se decida pipeline)
EOF

# ─── ADR-001 stub ───────────────────────────────────────────────
echo "${DIM}🧭 Creando ADR-001 stub con la decisión de stack...${RESET}"

cat > "$TARGET_DIR/decisions.md" << EOF
# 🧭 decisions.md — Architecture Decision Records (ADRs)

> **Última actualización**: $TODAY
> **Audiencia**: agentes + futuros devs.
> **Propósito**: registro de decisiones importantes con contexto + alternativas + consecuencias.
> **Cuándo crear nuevo ADR**: decisión arquitectónica importante (no toda decisión).

---

## ¿Qué es un ADR y cuándo crear uno?

**Crear ADR cuando**:
- Decisión afecta arquitectura cross-cutting
- Alternativas tienen trade-offs no obvios
- Decisión va a ser cuestionada en el futuro
- Cambiarla cuesta >1 día de trabajo

**NO crear ADR cuando**:
- Decisión trivial (naming de variable, qué library de utils)
- Revertible en <1 día sin costo

---

## Status legend

- **Proposed**: en discusión
- **Accepted**: vigente
- **Superseded by ADR-XXX**: reemplazada
- **Deprecated**: ya no aplica pero queda como historia

## Severity legend

- **Foundational**: cambiarla = rewrite del proyecto
- **Major**: cambiarla = sprint completo de refactor
- **Minor**: cambiarla = días de trabajo

---

## Índice de ADRs

| # | Título | Status | Severity | Date |
|---|--------|--------|----------|------|
| 001 | Stack inicial: $STACK | Accepted | Foundational | $TODAY |

---

## ADR-001: Stack inicial — $STACK

**Date**: $TODAY
**Status**: Accepted
**Severity**: Foundational

### Context

Arranque del proyecto $PROJECT_NAME. Hay que elegir stack base para
backend, frontend, DB y hosting que permita iterar rápido en MVP y
escalar después sin rewrite.

### Decision

**Stack elegido**: $STACK

Detalles:
- **Backend**: $STACK_BACKEND
- **Runtime**: $STACK_RUNTIME
- **Package manager**: $STACK_PKG
- **Framework recomendado**: $STACK_FW_HINT
- **Frontend, DB, hosting**: TBD (ir documentando en \`tech-context.md\` y nuevos ADRs)

### Alternatives considered

- **Alternativa A**: (TODO: completar — qué otra stack se consideró y por qué se rechazó)
- **Alternativa B**: (TODO: completar)

### Consequences

- ✅ (TODO: beneficios concretos de este stack)
- ⚠️ (TODO: trade-offs aceptados)
- 🚫 (TODO: cosas que ya NO podemos hacer fácil con este stack)
EOF

# ─── Active-context.md inicial ──────────────────────────────────
cat > "$TARGET_DIR/active-context.md" << EOF
# 🎯 active-context.md — Lo que estamos haciendo AHORA

> **Última actualización**: $TODAY
> **Audiencia**: agentes de IA (especialmente para contexto de arranque).
> **Propósito**: tracker sesión-a-sesión de qué pasó. Updates al tope con fecha.
> **Cuándo actualizar**: cada sesión que produce cambios. Sin excepciones.

---

## Update $TODAY — Bootstrap del proyecto $PROJECT_NAME

**Estado**: ⏳ inicial

### Qué se hizo
- Bootstrap del AI Agent Harness (13 docs + estructura)
- Stack elegido: $STACK
- ADR-001 creado con decisión de stack (pendiente completar alternatives + consequences)

### Próximos pasos
- Completar \`product-context.md\` con visión + audiencia del producto
- Completar ADR-001 en \`decisions.md\` (alternatives + consequences)
- Empezar el código del backend
- Cuando aparezca primera feature: agregar entry a \`progress.md\`

### Memorias relacionadas
- (vacío todavía)

---
EOF

# ─── Progress.md inicial ────────────────────────────────────────
cat > "$TARGET_DIR/progress.md" << EOF
# ✅ progress.md — Qué funciona vs qué está pendiente

> **Última actualización**: $TODAY
> **Audiencia**: agentes + team.
> **Propósito**: tracker de features por época, con estado y commit.
> **Cuándo actualizar**: cada feature cerrada o bundle de cambios.

---

## Época 0 — Bootstrap ($TODAY)

**Status global**: ⏳ inicial · proyecto recién creado

| # | Feature | Estado | Detalle | Commit |
|---|---------|--------|---------|--------|
| 1 | AI Agent Harness instalado | ✅ | 13 docs + skeleton structure + ADR-001 stub | (init) |

---
EOF

# ─── Git init opcional ──────────────────────────────────────────
if [[ "$INIT_GIT" =~ ^[Yy]$ ]]; then
  if [[ ! -d "$(pwd)/.git" ]]; then
    echo "${DIM}🔧 git init...${RESET}"
    git init -q
    git add docs/
    git commit -q -m "chore: bootstrap AI Agent Harness (13 docs)"
    echo "${DIM}   ✓ Initial commit creado${RESET}"
  else
    echo "${DIM}   ℹ Ya existe .git — skip${RESET}"
  fi
fi

# ─── Resultado + guía ───────────────────────────────────────────
echo ""
echo "${BOLD}${GREEN}✅ Harness instalado en $TARGET_DIR${RESET}"
echo ""
echo "${BOLD}📋 Próximos pasos (en orden):${RESET}"
echo ""
echo "  ${YELLOW}1.${RESET} Editar ${CYAN}docs/product-context.md${RESET}"
echo "     → ¿Qué hace tu app?, audiencia, modelo de negocio"
echo ""
echo "  ${YELLOW}2.${RESET} Completar ${CYAN}docs/decisions.md${RESET} ADR-001"
echo "     → Alternatives considered + Consequences (el stub está listo)"
echo ""
echo "  ${YELLOW}3.${RESET} Completar ${CYAN}docs/tech-context.md${RESET}"
echo "     → Frontend, DB, hosting, env vars (a medida que decidas)"
echo ""
echo "  ${YELLOW}4.${RESET} Al codear:"
echo "     • Feature cerrada → entry en ${CYAN}docs/progress.md${RESET}"
echo "     • Bug encontrado → entry en ${CYAN}docs/known-issues.md${RESET}"
echo "     • Sesión productiva → entry al tope de ${CYAN}docs/active-context.md${RESET}"
echo ""
echo "  ${YELLOW}5.${RESET} Primera integración externa (Stripe, OAuth, ...)"
echo "     → Documentar en ${CYAN}docs/integrations.md${RESET}"
echo ""
echo "${BOLD}📖 Ver ${CYAN}docs/README.md${RESET}${BOLD} para guía completa.${RESET}"
echo ""
echo "${BOLD}🤖 Tip para agentes AI${RESET}"
echo "${DIM}Configurá tu agente (Claude Code / Cursor / Cline / Antigravity) para que${RESET}"
echo "${DIM}lea ${CYAN}docs/README.md${RESET}${DIM} al inicio de cada sesión. Va a entender el proyecto${RESET}"
echo "${DIM}en minutos en vez de grep-and-pray.${RESET}"
echo ""
