# 🌐 deploy-to-vercel.md — Deploy automático en Vercel

> **Última actualización**: {{YYYY-MM-DD}}
> **Audiencia**: vos (o tu agente AI) cuando deploys la primera vez
> **Propósito**: guía paso-a-paso desde cero a app live
> **Cuándo actualizar**: cuando cambia el flow de deploy o se agregan servicios

> 🌐 **Aplica al path Vercel/Cloud Managed**.

---

## ✨ Por qué Vercel

- ✅ **Setup en 5 minutos** (de verdad)
- ✅ **Free tier suficiente** para apps personales / MVPs / portfolios
- ✅ **SSL automático** (https://tu-app.vercel.app)
- ✅ **Deploy automático** en cada `git push` a main
- ✅ **Sin Docker ni servidores ni SSH**

⚠️ Limitaciones del free tier:
- 100 GB bandwidth/mes (suficiente hasta ~5k visits/mes)
- 100h compute time/mes (alcanza para apps chicas)
- Sin custom domain en algunas features (precisás Pro $20/mes)
- Functions con timeout 10s (Pro: 60s)

---

## 🚀 Paso a paso — primer deploy

### Paso 1 — Crear cuenta Vercel

1. Andá a https://vercel.com/signup
2. Click "Continue with GitHub" (lo más fácil)
3. Autorizá Vercel a leer tus repos

### Paso 2 — Subir tu código a GitHub

```bash
# Si todavía no tenés repo en GitHub
gh repo create {{nombre-repo}} --public --source=. --push

# O manualmente:
# 1. github.com/new → crear repo vacío
# 2. git remote add origin https://github.com/{{user}}/{{repo}}.git
# 3. git push -u origin main
```

### Paso 3 — Importar el proyecto a Vercel

1. En vercel.com → click **"Add New..."** → **Project**
2. Buscar tu repo recién pusheado → click **Import**
3. Vercel detecta automáticamente el framework (Next.js, Astro, Vue, etc.)
4. **NO TOQUES** las settings (los defaults están bien para empezar)
5. Click **Deploy**

### Paso 4 — Configurar variables de entorno

Tu `.env` local NO se sube a Git (está gitignored). Hay que **agregar las env vars en Vercel**:

1. En el dashboard del proyecto → **Settings** → **Environment Variables**
2. Agregar una por una (copiar de tu `.env` local):
   - Name: `DATABASE_URL`
   - Value: `tu valor`
   - Environment: ✅ Production, ✅ Preview, ✅ Development
3. **Redeploy** después de agregar las vars (Deployments → último → Redeploy)

### Paso 5 — Custom domain (opcional)

Si tenés un dominio propio (`tu-app.com`):

1. Settings → Domains → Add
2. Escribir `tu-app.com`
3. Vercel te muestra los DNS records a agregar en tu registrar
4. Esperar propagación (1-30 min) → SSL se emite solo

**Si NO tenés dominio**: tu URL es `https://{{proyecto}}.vercel.app` — funciona perfecto.

---

## 🛠️ Servicios managed recomendados (combo Vercel)

### DB → Supabase (Postgres managed)

1. https://supabase.com/dashboard → New Project
2. Region: más cerca de tus usuarios
3. Anotar el **connection string** (Settings → Database → URI)
4. En Vercel env vars: `DATABASE_URL` = el connection string

**Free tier**: 500 MB DB + 2GB bandwidth/mes.
**Pro**: $25/mes cuando crezcas.

### Auth → Clerk (la opción más fácil)

1. https://clerk.com/dashboard → Create application
2. Elegir auth methods (email + Google + GitHub son default)
3. Copiar `CLERK_PUBLISHABLE_KEY` + `CLERK_SECRET_KEY`
4. En Vercel env vars: agregar ambas

**Free tier**: 10,000 monthly active users.
**Pro**: $25/mes cuando pases.

### Email → Resend

1. https://resend.com/signup
2. Agregar tu dominio (verificar DNS)
3. Copiar API key
4. En Vercel env vars: `RESEND_API_KEY`

**Free tier**: 3000 emails/mes.

---

## 🔁 Workflow diario después del primer deploy

```bash
# 1. Trabajás localmente
npm run dev

# 2. Cuando estés conforme, commit + push
git add .
git commit -m "feat: nueva feature X"
git push

# 3. Vercel auto-deploya en <2 min
#    → recibís email/notif cuando termina
```

### Preview deployments

**Cada Pull Request** crea un deploy preview con URL única (`pr-123.vercel.app`).
Útil para testear features antes de mergear a main.

---

## 💸 Cuándo Vercel se vuelve caro — el aviso honesto

⚠️ **El path Vercel es EXCELENTE para arrancar, pero CARO cuando crecés**.

Si tu app empieza a tener tracción:
- Vercel Pro: $20/mes por persona del team
- Supabase Pro: $25/mes (500MB → 8GB)
- Clerk Pro: $25/mes (10k → ilimitados MAU)
- **Total: $70+/mes mínimo apenas validás producto**

A los 500-1000 usuarios pagos, esto puede llegar a $200-500/mes.

### Cuándo considerar migrar a path VPS

| Métrica | Threshold | Acción |
|---|---|---|
| Facturación Vercel/Supabase/Clerk combinada | >$50/mes | Considerar VPS |
| Usuarios activos pagos | >100 | Definitivamente VPS |
| Bandwidth Vercel | >50 GB/mes | Probable migración |
| Functions hitting timeout | Frecuente | Vercel Pro o VPS |

→ Cuando cumplas alguna, hacé `harness upgrade --to=vps` y migrás al path Publiafy.

Ver [`cloud-services-costs.md`](cloud-services-costs.md) para detalle de cuánto cuesta cada servicio managed cuando crece.

---

## 🐛 Troubleshooting Vercel

### "Build failed: command not found"
→ Faltan scripts en `package.json`. Verificá que tengas `"build": "..."`.

### "Environment variable X is not defined"
→ La olvidaste agregar en Settings → Environment Variables. Después de agregar: redeploy.

### "Function timeout"
→ Algún endpoint tarda >10s (free tier). Soluciones:
1. Upgrade a Pro ($20/mes — 60s timeout)
2. Mover ese endpoint a un VPS / Edge Function
3. Optimizar el endpoint (caching, paginación)

### "Build succeeds but app shows 404"
→ Verificá output dir en Vercel settings (debe ser `.next/` para Next.js, `dist/` para Vite, etc.)

---

## Referencias

- [`tech-context.md`](tech-context.md) — stack técnico
- [`cloud-services-costs.md`](cloud-services-costs.md) — costos reales escalando
- [`integrations.md`](integrations.md) — Supabase + Clerk + Resend setup
- [`decisions.md`](decisions.md) — ADR sobre elección Vercel vs VPS
