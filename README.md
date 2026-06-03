# 🤖 AI Agent Harness Template

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Use this template](https://img.shields.io/badge/Use%20this-template-2ea44f?logo=github)](https://github.com/Riccrack/ai-agent-harness-template/generate)
[![Made for AI agents](https://img.shields.io/badge/built%20for-AI%20agents-blueviolet)](#)
[![Docs: 13 files](https://img.shields.io/badge/docs-13%20files-informational)](#-qué-incluye)

> **13 markdown docs that turn any project into an AI-agent-friendly codebase.**

Plantilla reusable de documentación para proyectos donde colaborás con agentes de IA (Claude Code, Cline, Cursor, Antigravity, Aider, etc.).

Basado en el [Memory Bank pattern de Cline](https://github.com/cline/cline), extendido con 6 docs adicionales necesarios para proyectos serios (ADRs, runbook, integrations, security, glossary, lessons-learned).

**Probado en producción** en Publiafy (SaaS multi-tenant con 60+ migraciones, 28 routers backend, 38 services, integraciones con Meta/TikTok/Stripe/Gemini).

---

## ⚡ Quick start

### Opción A — Wizard interactivo (recomendado)

```bash
# 1. Clonar el template
npx degit Riccrack/ai-agent-harness-template ~/.ai-harness

# 2. En tu nuevo proyecto
cd mi-nueva-app
~/.ai-harness/init-harness.sh
```

El wizard te pregunta:
- Nombre del proyecto
- Owner / autor (auto-detect de git config)
- Idioma del contenido (es / en / pt)
- Stack principal (Node / Python / Ruby / Go / Rust / PHP / Java / Otro)
- Si querés `git init` automático

Y te deja los 13 docs llenos con pre-fills según el stack elegido (incluyendo ADR-001 stub, tech-context.md adaptado, y entries iniciales en active-context + progress).

### Opción B — Solo skeleton (sin wizard)

```bash
npx degit Riccrack/ai-agent-harness-template/harness-skeleton mi-app/docs
# Reemplazás manualmente {{PROJECT_NAME}}, {{YYYY-MM-DD}}, {{OWNER}}
```

### Opción C — Template de GitHub (UI)

1. Click en **"Use this template"** (arriba a la derecha del repo)
2. Crea tu repo nuevo a partir del template
3. Clonalo y corré `./init-harness.sh`

---

## 🗺️ Qué incluye

13 docs en 4 categorías visuales:

### 🟢 STATE — El presente vivo
- `active-context.md` — qué se hace AHORA (sesión por sesión)
- `progress.md` — tracker features vs pendientes
- `known-issues.md` — bugs auditados
- `pendientes.md` — roadmap priorizado

### 🟡 CONTEXT — El entendimiento
- `product-context.md` — qué es el producto
- `tech-context.md` — stack técnico
- `system-patterns.md` — arquitectura y patterns
- `glossary.md` — vocabulario del dominio

### 🔵 KNOWLEDGE — La sabiduría meta
- `decisions.md` — ADRs (Architecture Decision Records)
- `lessons-learned.md` — patrones aprendidos por la mala

### 🟠 OPERATIONS — Cómo operamos
- `runbook.md` — procedimientos paso-a-paso
- `integrations.md` — APIs externas + quirks
- `security.md` — threat model + secret handling

---

## 🎯 ¿Por qué importa?

| Sin harness | Con harness |
|---|---|
| Agente AI gasta 30+ min grepping random | Agente lee 4 docs en 5 min y tiene 80% del contexto |
| Devs humanos onboarding: semanas | Devs humanos onboarding: horas |
| Bugs viejos se repiten | `known-issues.md` + `lessons-learned.md` previenen repetición |
| Decisiones se olvidan, se cuestionan | `decisions.md` preserva el "por qué" |
| Emergencias = improvisación | `runbook.md` da playbook claro |

---

## 📖 Cómo usar después del bootstrap

### Si sos agente de IA al iniciar sesión

**Lectura recomendada** (primeros 4 te dan 80% del contexto):
1. `active-context.md` → qué pasó la última sesión
2. `product-context.md` → qué construye el proyecto
3. `progress.md` → qué funciona ya
4. `known-issues.md` → qué bugs evitar
5. *(según tarea)* `tech-context.md` · `system-patterns.md` · `decisions.md`
6. *(emergencia)* `runbook.md` · `integrations.md` · `security.md`

### Si sos dev humano nuevo
1. `product-context.md` → qué es
2. `glossary.md` → vocabulario del equipo
3. `tech-context.md` → stack
4. `system-patterns.md` → cómo está armado
5. `decisions.md` → por qué se eligió X

### Si sos el mantenedor

| Evento | Update |
|---|---|
| Código nuevo | `progress.md` + `active-context.md` |
| Bug aparece | `known-issues.md` |
| Bug se repite 2+ veces | `lessons-learned.md` |
| Decisión arquitectónica | nuevo ADR en `decisions.md` |
| Cambio de stack | `tech-context.md` |
| Nueva integración externa | sección en `integrations.md` |
| Procedure nuevo (deploy, rollback) | sección en `runbook.md` |

---

## 📐 Convenciones

- **Naming**: kebab-case para `.md` files (excepto `README.md`)
- **Idioma**: usá el mismo que tu código/commits. Solo los nombres de archivos están en inglés para portabilidad
- **Emojis estándar**: 🔴 crítico · 🟠 alto · 🟡 medio · 🟢 bajo · ✅ hecho · ⏳ pendiente · 🚀 deployed · 🚨 emergencia · ⚠️ warning
- **Cross-references**: links relativos `[name](file.md)` clickeables
- **Archive**: cuando doc >50KB, mover entries >2 meses a `<doc>-archive-YYYY-Q.md`

---

## 🛠️ Instalación por herramienta de IA

Cada herramienta tiene su forma de auto-cargar contexto. Acá tenés el setup completo (bootstrap + configuración) para las más comunes:

### 🟣 Claude Code (CLI)

```bash
# 1. Bootstrap del harness en tu proyecto
cd mi-app
npx degit Riccrack/ai-agent-harness-template ~/.ai-harness
~/.ai-harness/init-harness.sh

# 2. Crear CLAUDE.md en la raíz (Claude Code lo lee automáticamente)
cat > CLAUDE.md << 'EOF'
# AI Agent Context

Este proyecto usa el AI Agent Harness Template. Al inicio de cada sesión:

1. Lee `docs/README.md` para entender la estructura
2. Lee estos 4 docs prioritarios (te dan 80% del contexto):
   - `docs/active-context.md` — qué pasó la última sesión
   - `docs/product-context.md` — qué es el proyecto
   - `docs/progress.md` — qué funciona ya
   - `docs/known-issues.md` — qué bugs evitar
3. Según la tarea, lee también: `tech-context.md`, `system-patterns.md`, `decisions.md`
4. En emergencias: `runbook.md`, `integrations.md`, `security.md`

## Reglas de mantenimiento de docs

- Al final de cada sesión productiva: update `active-context.md` + `progress.md`
- Bug nuevo → entrada en `known-issues.md`
- Bug repetido 2+ veces → lección en `lessons-learned.md`
- Decisión arquitectónica → nuevo ADR en `decisions.md`
EOF

# 3. Lanzar Claude Code en el proyecto
claude
```

### 🔵 Claude Code — extensión de VS Code

1. Instalar la extensión: `Cmd/Ctrl+Shift+X` → buscar **"Claude Code"** (de Anthropic) → Install
2. Bootstrap del harness igual que arriba (`npx degit ...` + `init-harness.sh`)
3. Crear `CLAUDE.md` igual que arriba (la extensión usa el mismo archivo)
4. Abrir el panel de Claude Code (`Cmd/Ctrl+Shift+P` → "Claude Code: Focus")
5. Listo — la extensión lee `CLAUDE.md` automáticamente al iniciar sesión

**Tip**: configurá `"claude-code.autoApprove": ["Read", "Grep", "Glob"]` en `settings.json` para que el agente pueda leer los docs del harness sin pedir permiso cada vez.

### 🖥️ Claude Code Desktop (app Mac/Windows)

1. Descargar de [claude.ai/download](https://claude.ai/download)
2. Abrir la app y conectar tu proyecto (`File → Open Folder`)
3. Bootstrap del harness igual que arriba
4. Crear `CLAUDE.md` igual que arriba
5. La app levanta el contexto automáticamente

**Bonus**: la app desktop tiene **slash commands** — podés crear `.claude/commands/refresh-context.md` con:
```markdown
Releé docs/active-context.md, docs/known-issues.md y docs/progress.md.
Resumime el estado actual del proyecto en 5 bullets.
```
Después corrés `/refresh-context` cuando arrancás una sesión.

### 🌌 Antigravity

1. Bootstrap del harness igual que arriba
2. Crear `agent.md` en la raíz del proyecto (Antigravity lo auto-carga):
```markdown
# Agent Context

Project uses AI Agent Harness Template. At session start, read:
- docs/README.md (structure)
- docs/active-context.md (latest session)
- docs/product-context.md (what this project is)
- docs/known-issues.md (bugs to avoid)

Update docs/active-context.md and docs/progress.md after every productive session.
```
3. Si Antigravity tiene memoria persistente, configurá:
```
@memory remember: this project uses AI Agent Harness — always read docs/ at session start
```

### 🟠 Cline (VS Code extension)

Cline soporta el patrón "Memory Bank" nativamente — el harness es 100% compatible.

1. Instalar Cline desde VS Code Marketplace
2. Bootstrap del harness:
```bash
cd mi-app
npx degit Riccrack/ai-agent-harness-template ~/.ai-harness
~/.ai-harness/init-harness.sh
```
3. Crear `.clinerules` en la raíz:
```
# Cline rules — AI Agent Harness

At session start, read in order:
1. docs/README.md
2. docs/active-context.md
3. docs/product-context.md
4. docs/known-issues.md

This project follows the AI Agent Harness pattern (extension of Cline's
Memory Bank). The 13 docs in docs/ are the source of truth for context.

After each productive session:
- Update docs/active-context.md (new entry at top)
- Update docs/progress.md (if features changed)
- Update docs/known-issues.md (if bugs appeared)
```
4. En la barra lateral de Cline, click el ícono **Memory Bank** → apuntalo a `docs/`

### 🎯 Cursor

1. Bootstrap del harness igual que arriba
2. Crear `.cursorrules` en la raíz:
```
Project uses AI Agent Harness Template (13 docs in docs/).

At session start, ALWAYS read:
- docs/README.md (harness structure)
- docs/active-context.md (latest work)
- docs/product-context.md (what this is)
- docs/known-issues.md (bugs to avoid)

When the task involves: architecture → also read docs/decisions.md and
docs/system-patterns.md. When debugging → also read docs/lessons-learned.md.
When deploying or troubleshooting → also read docs/runbook.md.

After productive sessions, update docs/active-context.md and docs/progress.md.
```
3. Reload Cursor — las reglas se aplican automáticamente

**Alternativa moderna**: si tu Cursor soporta `.cursor/rules/*.mdc`, podés crear `.cursor/rules/harness.mdc` con el mismo contenido + frontmatter `alwaysApply: true`.

### 🟢 Aider

```bash
# 1. Bootstrap
npx degit Riccrack/ai-agent-harness-template ~/.ai-harness
~/.ai-harness/init-harness.sh

# 2. Crear alias para auto-cargar los docs prioritarios
alias aider-harness='aider \
  --read docs/README.md \
  --read docs/active-context.md \
  --read docs/product-context.md \
  --read docs/known-issues.md \
  --read docs/progress.md'

# 3. Usar
aider-harness
```

O configurar en `.aider.conf.yml`:
```yaml
read:
  - docs/README.md
  - docs/active-context.md
  - docs/product-context.md
  - docs/known-issues.md
  - docs/progress.md
```

### 🤖 Continue.dev (VS Code / JetBrains)

1. Instalar Continue
2. Bootstrap del harness igual que arriba
3. En `.continue/config.json`, agregar context provider:
```json
{
  "contextProviders": [
    {
      "name": "folder",
      "params": { "folders": ["docs"] }
    }
  ]
}
```
4. Usar `@docs` en el chat para que Continue cargue todo el harness como contexto

### 📦 Tabla comparativa de archivos de configuración

| Herramienta | Archivo de config | Auto-load |
|---|---|---|
| Claude Code (CLI) | `CLAUDE.md` | ✅ |
| Claude Code (VS Code ext) | `CLAUDE.md` | ✅ |
| Claude Code (Desktop) | `CLAUDE.md` + `.claude/commands/` | ✅ |
| Antigravity | `agent.md` | ✅ |
| Cline | `.clinerules` | ✅ |
| Cursor | `.cursorrules` o `.cursor/rules/*.mdc` | ✅ |
| Aider | `.aider.conf.yml` o flags `--read` | ⚠️ flag manual |
| Continue.dev | `.continue/config.json` + `@docs` | ⚠️ trigger manual |

---

## 🎁 Ejemplo en producción

[Publiafy](https://publiafy.com) (SaaS multi-tenant de gestión social media + IA generativa) usa este harness con los 13 docs llenos, ~250KB de docs vivos. El código es privado, pero la app es el caso de prueba real del harness.

---

## 🤝 Contribuir

PRs bienvenidos. Ideas:
- Skeletons adicionales (`api-contracts.md`, `frontend-architecture.md`, etc.)
- Variantes pre-armadas por stack (Next.js, Rails, Django, Spring)
- GitHub Action que valide la estructura del harness
- Linter de docs (verifica que entries tengan fecha, severidad, commit)
- VS Code extension con snippets para entries comunes
- MCP server que exponga los docs a agentes vía protocolo estándar

Ver [`HOW_TO_CONTRIBUTE.md`](./HOW_TO_CONTRIBUTE.md) (próximamente).

---

## 📜 Licencia

MIT — usá esto en cualquier proyecto, comercial o no.

---

<div align="center">

**Si te sirvió, dale ⭐ al repo.**

Hecho con ❤️ desde México.

</div>
