# 🧭 decisions.md — Architecture Decision Records (ADRs)

> **Última actualización**: {{YYYY-MM-DD}}
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
- Ya tiene precedente claro en el codebase

---

## Status legend

- **Proposed**: en discusión
- **Accepted**: vigente
- **Superseded by ADR-XXX**: reemplazada por otra
- **Deprecated**: ya no aplica pero queda como historia

## Severity legend

- **Foundational**: cambiarla = rewrite del proyecto
- **Major**: cambiarla = sprint completo de refactor
- **Minor**: cambiarla = días de trabajo

---

## Índice de ADRs

| # | Título | Status | Severity | Date |
|---|--------|--------|----------|------|
| 001 | ... | Accepted | Foundational | {{YYYY-MM-DD}} |

---

## ADR-001: {{Título corto}}

**Date**: {{YYYY-MM-DD}}
**Status**: Accepted
**Severity**: Major

### Context

{{Qué problema/situación llevó a esta decisión}}

### Decision

{{Qué se decidió hacer}}

### Alternatives considered

- **Alternativa A**: {{descripción}} — rechazada porque {{razón}}.
- **Alternativa B**: {{descripción}} — rechazada porque {{razón}}.

### Consequences

- ✅ {{Beneficio 1}}
- ✅ {{Beneficio 2}}
- ⚠️ {{Trade-off aceptado}}
- 🚫 {{Cosa que ya NO podemos hacer fácil}}
