import { Router } from 'express';

export const mlRouter = Router();

function mlStatusTimeoutMs() {
  const a = Number(process.env.ML_STATUS_TIMEOUT_MS);
  if (Number.isFinite(a) && a > 0) return Math.min(a, 60_000);
  const b = Number(process.env.ML_TIMEOUT_MS);
  if (Number.isFinite(b) && b > 0) return Math.min(b, 60_000);
  return 15_000;
}

/**
 * Proxies ML bridge /health so ops can check Node + ML in one place.
 */
mlRouter.get('/status', async (_req, res) => {
  const base = (process.env.ML_SERVICE_URL || 'http://127.0.0.1:5042').replace(/\/$/, '');
  const enabled = process.env.ML_ENABLED !== 'false';
  if (!enabled) {
    return res.json({
      mlEnabled: false,
      mlServiceUrl: base,
      bridge: null,
      note: 'Set ML_ENABLED=true and run npm run ml:bridge',
    });
  }
  try {
    const controller = new AbortController();
    const ms = mlStatusTimeoutMs();
    const t = setTimeout(() => controller.abort(), ms);
    const r = await fetch(`${base}/health`, { signal: controller.signal });
    clearTimeout(t);
    const body = await r.json().catch(() => ({}));
    return res.json({
      mlEnabled: true,
      mlServiceUrl: base,
      bridge: { ok: r.ok, status: r.status, body },
    });
  } catch (e) {
    const err = String(e?.message || e);
    return res.status(503).json({
      mlEnabled: true,
      mlServiceUrl: base,
      bridge: { ok: false, error: err },
      hint:
        'Docker Compose: api konteynerinde ML_SERVICE_URL=http://ml:5050 olmalı (127.0.0.1:5042 konteyner içi yanlış). `docker compose ps` ile ml servisinin Up olduğunu ve ./backend/ml mount edildiğini doğrulayın.',
    });
  }
});
