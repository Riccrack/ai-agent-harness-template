# 🏗️ system-patterns.md — Arquitectura y patrones

> **Última actualización**: {{YYYY-MM-DD}}
> **Audiencia**: agentes de IA.
> **Propósito**: patrones de implementación, contratos, reglas. El "cómo y por qué", no el "qué".
> **Cuándo actualizar**: cuando aparece un patrón nuevo reusable.

---

## Arquitectura general

{{Diagrama ASCII o descripción de capas + flujo}}

## Patrón 1: {{Nombre}}

**Contexto**: cuándo aplica.
**Implementación**: cómo se hace.
**Por qué**: razón del diseño.
**Archivos relevantes**: `path/to/X.js`

## Patrón 2: ...

(repetir estructura)

---

## Patrones críticos de implementación

- **Circular deps**: cómo se manejan.
- **Race conditions**: patrones de lock / idempotencia.
- **Error handling**: estrategia cross-cutting.
- **Observability**: logging conventions.

## Defensa en capas (si aplica)

{{Diagrama: middleware → auth → cap → handler}}
