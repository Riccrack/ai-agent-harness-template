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

## 🤖 Configurar tu agente AI para leer los docs

### Claude Code

Crear `CLAUDE.md` en la raíz del proyecto:
```markdown
Al inicio de cada sesión, leé `docs/README.md` y los 4 docs prioritarios:
`active-context.md`, `product-context.md`, `progress.md`, `known-issues.md`.
```

### Cursor / Cline

Crear `.cursorrules`:
```
Read docs/README.md at session start to understand the project structure.
Key docs to always check: docs/active-context.md, docs/known-issues.md.
After every productive session, update docs/active-context.md and docs/progress.md.
```

### Aider

```bash
aider --read docs/README.md --read docs/active-context.md --read docs/known-issues.md
```

### Antigravity

Configurá tu agent context para auto-cargar `docs/` al iniciar.

---

## 🎁 Ejemplo en producción

[Publiafy](https://github.com/Riccrack/Publiafy/tree/main/docs) usa este harness con los 13 docs llenos. Buen referente para ver cómo queda un proyecto real con ~250KB de docs vivos.

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

Hecho con ❤️ desde Buenos Aires.

</div>
