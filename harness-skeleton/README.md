# 📚 Docs Harness — {{PROJECT_NAME}}

> **Última actualización**: {{YYYY-MM-DD}}
> **Audiencia**: agentes de IA (Claude Code, Cline, Cursor, Antigravity, Aider) + devs humanos.
> **Propósito**: AI agent harness — 13 docs que un agente lee al iniciar sesión para entender el proyecto.

## 🗺️ Mapa de docs

### 🟢 STATE (alta frecuencia)
- [`active-context.md`](active-context.md) — qué se hace AHORA
- [`progress.md`](progress.md) — qué funciona vs pendiente
- [`known-issues.md`](known-issues.md) — bugs auditados
- [`pendientes.md`](pendientes.md) — roadmap priorizado

### 🟡 CONTEXT (baja frecuencia)
- [`product-context.md`](product-context.md) — qué es el producto
- [`tech-context.md`](tech-context.md) — stack y catálogo técnico
- [`system-patterns.md`](system-patterns.md) — arquitectura y patrones
- [`glossary.md`](glossary.md) — vocabulario del dominio

### 🔵 KNOWLEDGE (incremental)
- [`decisions.md`](decisions.md) — Architecture Decision Records (ADRs)
- [`lessons-learned.md`](lessons-learned.md) — patrones que descubrimos por la mala

### 🟠 OPERATIONS (referencia)
- [`runbook.md`](runbook.md) — procedimientos paso-a-paso
- [`integrations.md`](integrations.md) — APIs externas y quirks
- [`security.md`](security.md) — threat model y secret handling

## 🚀 Cómo usar

**Agente de IA al iniciar sesión** — leer en orden: `active-context.md` → `product-context.md` → `progress.md` → `known-issues.md`. Resto según tarea.

**Dev humano nuevo** — `product-context.md` → `glossary.md` → `tech-context.md` → `system-patterns.md` → `decisions.md`.

**Owner al cerrar feature** — update `progress.md` + `active-context.md` + (si hubo bugs) `known-issues.md`.

## 📐 Convenciones

- Naming: kebab-case
- Emojis estándar: 🔴 crítico · 🟠 alto · 🟡 medio · 🟢 bajo · ✅ hecho · ⏳ pendiente · 🚀 deployed · 🚨 emergencia
- Cross-references: links relativos clickeables `[name](file.md)`
- Archive policy: docs >50KB, mover entries >2 meses a `<doc>-archive-YYYY-Q.md`

## 🎁 Template origen

Esta estructura se clonó del [template Publiafy](https://github.com/...) — ver [`docs/templates/`](templates/) para copiar a otros proyectos.
