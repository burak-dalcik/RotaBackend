/**
 * OpenAPI 3.0 — Swagger UI (`/api-docs`) için tek kaynak.
 * @param {{ publicUrl?: string | null }} opts
 */
export function buildOpenApiDocument(opts = {}) {
  const base = (opts.publicUrl || '').replace(/\/$/, '');
  const servers = base
    ? [{ url: base, description: 'Production (PUBLIC_API_URL)' }, { url: '/', description: 'Same origin' }]
    : [{ url: '/', description: 'Current host' }];

  return {
    openapi: '3.0.3',
    info: {
      title: 'Rota API',
      version: '1.0.0',
      description: 'IETT datathon — durak yaklaşan seferler ve ML köprüsü.',
    },
    servers,
    tags: [
      { name: 'meta', description: 'Sağlık ve özet' },
      { name: 'ml', description: 'ML servis durumu' },
      { name: 'stops', description: 'Duraklar' },
    ],
    paths: {
      '/': {
        get: {
          tags: ['meta'],
          summary: 'API özeti',
          responses: {
            200: {
              description: 'Servis adı ve endpoint listesi',
              content: { 'application/json': { schema: { $ref: '#/components/schemas/RootResponse' } } },
            },
          },
        },
      },
      '/health': {
        get: {
          tags: ['meta'],
          summary: 'Sağlık kontrolü',
          description: 'Node süreci, veri kaynağı (postgresql | memory), ML ayarları.',
          responses: {
            200: {
              description: 'OK',
              content: { 'application/json': { schema: { $ref: '#/components/schemas/HealthResponse' } } },
            },
          },
        },
      },
      '/api/v1/ml/status': {
        get: {
          tags: ['ml'],
          summary: 'ML servis durumu',
          description: 'Python ML servisine canlı HTTP isteği (`bridge.ok`).',
          responses: {
            200: { description: 'ML kapalı veya köprü yanıt verdi' },
            503: { description: 'ML açık ama servis ulaşılamıyor' },
          },
        },
      },
      '/api/v1/stops': {
        get: {
          tags: ['stops'],
          summary: 'Durak listesi',
          description: 'Veritabanındaki duraklar ve 60 dk içindeki en yakın şablon sefer (hat + dk).',
          responses: {
            200: {
              description: 'Durak özetleri',
              content: {
                'application/json': {
                  schema: { type: 'array', items: { $ref: '#/components/schemas/StopSummary' } },
                },
              },
            },
          },
        },
      },
      '/api/v1/stops/{durakKodu}': {
        get: {
          tags: ['stops'],
          summary: 'Durak bilgisi',
          parameters: [
            {
              name: 'durakKodu',
              in: 'path',
              required: true,
              schema: { type: 'string', example: 'KAD-MRK' },
            },
          ],
          responses: {
            200: {
              description: 'Meta',
              content: { 'application/json': { schema: { $ref: '#/components/schemas/StopMeta' } } },
            },
            404: { description: 'Bilinmeyen durak kodu' },
          },
        },
      },
      '/api/v1/stops/{durakKodu}/approaching-buses': {
        get: {
          tags: ['stops'],
          summary: 'Yaklaşan otobüsler',
          parameters: [
            {
              name: 'durakKodu',
              in: 'path',
              required: true,
              schema: { type: 'string', example: 'KAD-MRK' },
              description: 'Durak kodu (ör. bellek verisinde KAD-MRK, BES-MYD, KAD-SHL)',
            },
          ],
          responses: {
            200: {
              description: 'Sefer listesi',
              content: {
                'application/json': {
                  schema: { type: 'array', items: { $ref: '#/components/schemas/ApproachingBus' } },
                },
              },
            },
          },
        },
      },
    },
    components: {
      schemas: {
        ApproachingBus: {
          type: 'object',
          properties: {
            hatKodu: { type: 'string' },
            hatAdi: { type: 'string' },
            kalanSureDk: { type: 'number' },
            dolulukOrani: { type: 'number' },
            engelliErisimi: { type: 'boolean' },
            beklenenYolcu: { type: 'integer', description: 'Tahmini yolcu (ML veya yedek)' },
            mlTahmin: { type: 'boolean', description: 'true: XGBoost cevabı kullanıldı' },
            aracKapasitesi: { type: 'integer', description: 'Araç kapasitesi (doluluk paydası)' },
          },
        },
        StopMeta: {
          type: 'object',
          properties: {
            durakKodu: { type: 'string' },
            durakAdi: { type: 'string' },
            engelliErisimi: { type: 'boolean' },
          },
        },
        StopSummary: {
          type: 'object',
          properties: {
            durakKodu: { type: 'string' },
            durakAdi: { type: 'string' },
            engelliErisimi: { type: 'boolean' },
            enYakinSeferDk: { type: 'number', nullable: true },
            enYakinHatKodu: { type: 'string', nullable: true },
          },
        },
        RootResponse: {
          type: 'object',
          properties: {
            service: { type: 'string' },
            message: { type: 'string' },
            endpoints: {
              type: 'array',
              items: {
                type: 'object',
                properties: {
                  method: { type: 'string' },
                  path: { type: 'string' },
                  description: { type: 'string' },
                },
              },
            },
          },
        },
        HealthResponse: {
          type: 'object',
          properties: {
            ok: { type: 'boolean' },
            service: { type: 'string' },
            publicUrl: { type: 'string', nullable: true },
            dataSource: { type: 'string', enum: ['postgresql', 'memory'] },
            ml: {
              type: 'object',
              properties: {
                enabled: { type: 'boolean' },
                serviceUrl: { type: 'string' },
              },
            },
            endpoints: { type: 'array' },
            howToVerify: { type: 'object', additionalProperties: { type: 'string' } },
          },
        },
      },
    },
  };
}
