# 💻 local-setup.md — Cómo correr la app en tu computadora

> **Última actualización**: {{YYYY-MM-DD}}
> **Audiencia**: vos o quien clone el repo
> **Propósito**: setup paso-a-paso para correr la app en localhost
> **Cuándo actualizar**: cuando cambia algo del setup (nueva dep, comando, env var)

> 💻 **Aplica al path Local-only**.
> Si vas a Vercel/VPS, este doc también sirve para tu desarrollo local.

---

## 📋 Pre-requisitos

Antes de correr la app, instalar:

| Tool | Versión | Cómo verificar | Cómo instalar |
|---|---|---|---|
| Node.js | 20+ | `node --version` | https://nodejs.org |
| Git | Cualquiera reciente | `git --version` | https://git-scm.com/downloads |
| {{Otros: Docker / Postgres / etc.}} | | | |

---

## 🚀 Primer arranque (una sola vez)

```bash
# 1. Clonar el repo
git clone {{url-del-repo}}
cd {{nombre-del-repo}}

# 2. Instalar dependencias
npm install

# 3. Copiar el archivo de variables de entorno
cp .env.example .env

# 4. Editar .env con tus valores locales
#    (las explicaciones de cada variable están en .env.example)

# 5. (Si usás DB) Inicializar la DB local
{{npm run db:migrate o equivalente}}

# 6. Levantar la app en modo dev
npm run dev
```

→ Abrir `http://localhost:3000` en el browser.

---

## 🔁 Comandos cotidianos

| Tarea | Comando |
|---|---|
| Levantar dev server | `npm run dev` |
| Build de producción local | `npm run build` |
| Correr tests | `npm test` |
| Lint | `npm run lint` |
| {{Otros}} | |

---

## 🌐 Querés que alguien más pruebe tu app?

Tu app corre en `localhost:3000` — solo vos podés verla. Para mostrársela a alguien:

### Opción 1: ngrok (URL pública temporal — más fácil)

```bash
# Instalar ngrok una vez
npm install -g ngrok

# Compartir tu localhost en una URL pública (la URL cambia cada vez)
ngrok http 3000
```

→ ngrok te da una URL tipo `https://abc123.ngrok-free.app` que **cualquiera puede abrir**.
→ Free tier: URLs aleatorias. Plan paid ($8/mes): URL custom estable.

### Opción 2: Tailscale (LAN privada con amigos — gratis para uso personal)

Tailscale crea una "VPN privada" entre vos y quien invites. Tu app queda accesible solo para ellos.

1. Crear cuenta en https://tailscale.com (free para uso personal)
2. Instalar app en tu compu + en la de quien invites
3. Invitarlo via email a tu tailnet
4. Ellos abren `http://{{tu-machine-name}}:3000` en su browser

### Opción 3: Cloudflare Tunnel (URL pública estable, gratis)

Más setup pero más profesional. Te da una URL estable como `https://miapp.tu-dominio.com` sin necesidad de VPS:

1. Tener un dominio (≈ $10/año)
2. Cloudflare gratis + `cloudflared` CLI
3. `cloudflared tunnel create` → seguir wizard
4. Te queda una URL pública estable

Tiempo de setup: ~30 min. Worth it si vas a compartir seguido.

---

## 🗄️ DB local

### Si usás SQLite (recomendado para path local)

DB en un archivo `.db` local. Sin instalar nada extra.

```bash
# La DB se crea sola al primer arranque
npm run dev
# Archivo creado: ./local.db
```

Para inspeccionarla: instalar [DB Browser for SQLite](https://sqlitebrowser.org/) (gratis, multiplataforma).

### Si usás Postgres local

**Opción A — Postgres nativo**: instalar Postgres en tu compu (más config).

**Opción B — Postgres en Docker** (más simple):

```bash
docker run --name postgres-local \
  -e POSTGRES_PASSWORD=postgres \
  -p 5432:5432 \
  -d postgres:16
```

Luego en `.env`:
```
DATABASE_URL=postgres://postgres:postgres@localhost:5432/{{db}}
```

---

## 🐛 Troubleshooting común

### `Error: Cannot find module ...`
→ Te falta `npm install`.

### `EADDRINUSE: address already in use :::3000`
→ Algo más está usando el puerto 3000. Opciones:
1. Matá el proceso: `lsof -ti:3000 | xargs kill -9` (Mac/Linux)
2. Cambiá el puerto: `PORT=3001 npm run dev`

### `Permission denied` al correr scripts
→ `chmod +x script.sh`

### La app no encuentra mis env vars
→ Verificá:
1. El archivo se llama exactamente `.env` (no `.env.txt`)
2. Está en la raíz del proyecto
3. Reiniciá el dev server (las env vars se cargan al boot)

---

## ⏭️ Próximos pasos

Cuando tu app local funcione bien:

1. **Querés mostrarla a usuarios** → upgrade a path Vercel (`harness upgrade --to=vercel`)
2. **Querés venderla** → upgrade a path VPS (`harness upgrade --to=vps`)
3. **Solo seguís construyendo local** → mantener este path

Cada upgrade está documentado y NO destruye lo que ya tenés.

---

## Referencias

- [`tech-context.md`](tech-context.md) — stack técnico completo
- [`runbook.md`](runbook.md) — procedimientos comunes
- [`known-issues.md`](known-issues.md) — bugs conocidos
