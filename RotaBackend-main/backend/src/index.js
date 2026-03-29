import 'dotenv/config';
import express from 'express';
import cors from 'cors';
import swaggerUi from 'swagger-ui-express';
import { stopsRouter } from './routes/stops.js';
import { mlRouter } from './routes/ml.js';
import { buildOpenApiDocument } from './openapi.js';

/** Tek kaynak: tarayıcı / ve /health aynı listeyi gösterir */
const API_ENDPOINTS = [
  { method: 'GET', path: '/', description: 'Özet + endpoint listesi' },
  { method: 'GET', path: '/health', description: 'API ayakta mı, veri kaynağı, ML ayarları' },
  { method: 'GET', path: '/api-docs/', description: 'Swagger UI — interaktif dokümantasyon (Try it out)' },
  { method: 'GET', path: '/openapi.json', description: 'OpenAPI 3 şeması (JSON)' },
  { method: 'GET', path: '/api/v1/ml/status', description: 'Python ML servisine canlı ping (bridge.ok)' },
  { method: 'GET', path: '/api/v1/stops', description: 'Tüm duraklar + en yakın sefer özeti (liste)' },
  { method: 'GET', path: '/api/v1/stops/:durakKodu', description: 'Durak meta (ad, erişilebilirlik)' },
  {
    method: 'GET',
    path: '/api/v1/stops/:durakKodu/approaching-buses',
    description: 'Durak koduna göre yaklaşan seferler',
  },
];

const app = express();
const PORT = Number(process.env.PORT) || 3142;
const mlUrl = (process.env.ML_SERVICE_URL || 'http://127.0.0.1:5042').replace(/\/$/, '');

/** Nginx / load balancer arkasında doğru `req.ip` ve `X-Forwarded-*` için */
if (process.env.TRUST_PROXY === '1' || process.env.NODE_ENV === 'production') {
  app.set('trust proxy', 1);
}

/**
 * CORS: mobil uygulama (iOS/Android) CORS göndermez; Flutter Web ve tarayıcı için.
 * CORS_ORIGINS boş veya * ise tüm origin’lere izin (mevcut davranış).
 * Örnek: CORS_ORIGINS=https://app.example.com,https://gorisle.dalciksoft.com
 */
function corsOptions() {
  const raw = (process.env.CORS_ORIGINS || '').trim();
  if (!raw || raw === '*') {
    return { origin: true };
  }
  const list = raw.split(',').map((s) => s.trim()).filter(Boolean);
  return {
    origin(origin, callback) {
      if (!origin) return callback(null, true);
      callback(null, list.includes(origin));
    },
  };
}

app.use(cors(corsOptions()));
app.use(express.json());

const openApiDocument = buildOpenApiDocument({
  publicUrl: process.env.PUBLIC_API_URL?.trim() || null,
});

app.get('/openapi.json', (_req, res) => {
  res.json(openApiDocument);
});

app.use(
  '/api-docs',
  swaggerUi.serve,
  swaggerUi.setup(openApiDocument, {
    customSiteTitle: 'Rota API — Swagger',
    customCss: '.swagger-ui .topbar { display: none }',
  }),
);

app.get('/', (_req, res) => {
  res.json({
    service: 'Rota API',
    message:
      'Swagger arayüzü: /api-docs — Backend doğrulama: /health, ML: /api/v1/ml/status.',
    endpoints: API_ENDPOINTS,
  });
});

app.get('/health', (_req, res) => {
  res.json({
    ok: true,
    service: 'rota-backend',
    publicUrl: process.env.PUBLIC_API_URL || null,
    dataSource: process.env.DATABASE_URL?.trim() ? 'postgresql' : 'memory',
    ml: {
      enabled: process.env.ML_ENABLED !== 'false',
      serviceUrl: mlUrl,
    },
    endpoints: API_ENDPOINTS,
    howToVerify: {
      api: 'Bu yanıt HTTP 200 ve ok: true ise Node API süreci çalışıyor.',
      swagger: 'İnteraktif dokümantasyon: /api-docs/',
      database:
        'dataSource postgresql ise PostgreSQL kullanılıyor; memory ise örnek bellek verisi (DB yok).',
      ml: 'Tarayıcıda /api/v1/ml/status açın; bridge.ok true ve 200 ise ML servisi erişilebilir.',
    },
  });
});

app.use('/api/v1/ml', mlRouter);
app.use('/api/v1/stops', stopsRouter);

app.use((err, req, res, _next) => {
  console.error(`[${req.method}] ${req.path}:`, err);
  res.status(500).json({ error: 'Internal Server Error' });
});

app.listen(PORT, '0.0.0.0', () => {
  console.log(`Rota API listening on http://0.0.0.0:${PORT}`);
  console.log(`Swagger UI: http://0.0.0.0:${PORT}/api-docs/`);
  console.log(`ML bridge: ${mlUrl} (ML_ENABLED=${process.env.ML_ENABLED !== 'false'})`);
  if (process.env.PUBLIC_API_URL) {
    console.log(`Public URL (Flutter): ${process.env.PUBLIC_API_URL}`);
  }
});
