# Changelog

Todos los cambios notables del template se documentan acá.

Formato basado en [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
Versionado [SemVer](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.0] — 2026-06-03

### Added
- 13 skeleton docs en `harness-skeleton/`:
  - **STATE**: active-context, progress, known-issues, pendientes
  - **CONTEXT**: product-context, tech-context, system-patterns, glossary
  - **KNOWLEDGE**: decisions, lessons-learned
  - **OPERATIONS**: runbook, integrations, security
- Script `init-harness.sh` con wizard interactivo (nombre, owner, idioma, stack, git init)
- Stack-aware pre-fills para tech-context.md (Node / Python / Ruby / Go / Rust / PHP / Java / Otro)
- ADR-001 stub auto-generado en `decisions.md`
- Entradas iniciales en active-context.md y progress.md
- README con quick-start (degit, wizard, GitHub template UI)
- CONTRIBUTING.md con guía de contribución
- LICENSE MIT
- `.github/` con issue templates (bug, feature, skeleton proposal) + PR template
- `.gitignore` para outputs de testing

### Probado en producción
- Publiafy (SaaS multi-tenant, 60+ migraciones, 28 routers, 38 services)
