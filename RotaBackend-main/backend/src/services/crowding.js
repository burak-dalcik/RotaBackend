/**
 * Calls Python ML bridge (FastAPI) for XGBoost prediction, or fallback on failure / when disabled.
 */

function defaultResmitatil() {
  const r = (process.env.ML_DEFAULT_RESMITATIL || '').trim().toLowerCase();
  if (r === '1' || r === 'true') return 1;
  return 0;
}

function mockPrediction() {
  return Math.floor(10 + Math.random() * 91);
}

/** ML kapalı / hata: rastgele mock yerine 0 yolcu + fromMl:false (ML_USE_MOCK_ON_FAILURE=false) */
function useMockOnMlFailure() {
  const v = (process.env.ML_USE_MOCK_ON_FAILURE || 'true').trim().toLowerCase();
  return v !== '0' && v !== 'false' && v !== 'no';
}

/**
 * @typedef {{ passengers: number, fromMl: boolean }} MlPredictionRow
 */

/**
 * @param {string} hatKodu
 * @param {Date} arrivalDate
 * @param {number} kapasite
 * @returns {Promise<number>} expected passenger count (for doluluk ratio)
 */
export async function getAICrowdednessPrediction(hatKodu, arrivalDate, kapasite) {
  const [row] = await getAICrowdednessPredictionsBatch([
    { hatKodu, arrivalDate, kapasite: Math.max(1, Math.round(Number(kapasite) || 1)) },
  ]);
  return row.passengers;
}

/**
 * One HTTP call for multiple trips (POST /predict/batch).
 * @param {Array<{ hatKodu: string, arrivalDate: Date, kapasite: number }>} rows
 * @returns {Promise<MlPredictionRow[]>}
 */
export async function getAICrowdednessPredictionsBatch(rows) {
  const enabled = process.env.ML_ENABLED !== 'false';
  const base = (process.env.ML_SERVICE_URL || 'http://127.0.0.1:5042').replace(/\/$/, '');
  const resmitatil = defaultResmitatil();

  const fallbackRow = () => {
    if (useMockOnMlFailure()) {
      return { passengers: mockPrediction(), fromMl: false };
    }
    return { passengers: 0, fromMl: false };
  };

  if (!enabled || rows.length === 0) {
    return rows.map(() => fallbackRow());
  }

  try {
    const controller = new AbortController();
    const timeoutMs = Number(process.env.ML_TIMEOUT_MS) || 15000;
    const t = setTimeout(() => controller.abort(), timeoutMs);
    const res = await fetch(`${base}/predict/batch`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json', Accept: 'application/json' },
      body: JSON.stringify({
        items: rows.map((r) => ({
          hatKodu: r.hatKodu,
          kapasite: Math.max(1, Math.round(Number(r.kapasite) || 1)),
          arrivalTime: r.arrivalDate.toISOString(),
          resmitatil,
        })),
      }),
      signal: controller.signal,
    });
    clearTimeout(t);

    if (!res.ok) {
      const text = await res.text();
      console.error('[crowding] ML HTTP error', res.status, text.slice(0, 400));
      throw new Error(`ML ${res.status}: ${text}`);
    }

    const data = await res.json();
    const list = data.results;
    if (!Array.isArray(list) || list.length !== rows.length) {
      throw new Error('Invalid batch response shape');
    }
    if (list.length > 0 && process.env.ML_DEBUG_LOG === '1') {
      const first = list[0];
      const v = Number(first?.expectedPassengers ?? first?.expected_passengers);
      console.log('[crowding] ML batch ok, n=', list.length, 'firstExpectedPassengers=', v);
    }
    return list.map((item) => {
      const raw = Number(
        item.expectedPassengers ?? item.expected_passengers ?? item.expectedPassenger,
      );
      if (!Number.isFinite(raw)) {
        return useMockOnMlFailure()
          ? { passengers: mockPrediction(), fromMl: false }
          : { passengers: 0, fromMl: false };
      }
      // Çok küçük pozitif regresyon çıktıları 0’a yuvarlanmasın (ör. 0.4 → 1)
      const passengers = Math.max(0, Math.round(raw));
      const bumped = raw > 0 && passengers === 0 ? 1 : passengers;
      return { passengers: bumped, fromMl: true };
    });
  } catch (err) {
    console.error('[crowding] ML batch failed:', err?.message || err);
    return rows.map(() => fallbackRow());
  }
}
