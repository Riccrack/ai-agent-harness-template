# ⚙️ tech-context.md — Stack técnico de {{PROJECT_NAME}}

> **Última actualización**: {{YYYY-MM-DD}}
> **Audiencia**: agentes de IA.
> **Propósito**: catálogo técnico (no patrones — esos van a system-patterns).
> **Cuándo actualizar**: cuando se agregan rutas/servicios/migrations/deps mayores.

---

## Stack principal

| Categoría | Tech |
|-----------|------|
| Backend | ... |
| Frontend | ... |
| DB | ... |
| Auth | ... |
| Pagos | ... |
| AI/ML | ... |
| Contenedores | ... |
| Proxy | ... |

## Estructura de archivos

```
{{PROJECT_NAME}}/
├── backend/
├── frontend/
└── ...
```

## Rutas backend

| Prefijo | Archivo | Dominio |
|---------|---------|---------|
| `/api/...` | `routes/X.js` | ... |

## Servicios backend

| Grupo | Servicio |
|-------|----------|
| ... | ... |

## Páginas frontend

| Ruta | Página | Acceso |
|------|--------|--------|
| `/` | Landing | público |

## Schema de DB

{{Resumen tabular por dominio}}

## Variables de entorno

{{Crítico: documentar dónde viven (Portainer / .env / Secret Manager), NUNCA committed}}

## Deploy

{{Resumen del pipeline}}
