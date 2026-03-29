# Docker Compose (Rota)

Host portları **42** ile biter (VPS’te diğer projelerle çakışmayı azaltır). Konteyner **içi** portlar klasik: API `3000`, Postgres `5432`, ML `5050`.

## Çalıştırma

```bash
docker compose up -d --build
```

| Servis | Host (makinen) | Konteyner içi |
|--------|----------------|---------------|
| API | **http://localhost:3142** | 3000 |
| PostgreSQL | **localhost:5442** | 5432 |
| ML (debug) | **localhost:5042** | 5050 |

- DB: kullanıcı `rota`, şifre `rota123`, DB `rota`
- `api` → `DATABASE_URL` iç ağda `postgres:5432`, `ML_SERVICE_URL` `http://ml:5050`

## Yerel Node (`backend/.env`)

Postgres/ML Docker’da host portlarıyla: `5442`, `5042`, API `PORT=3142`.
