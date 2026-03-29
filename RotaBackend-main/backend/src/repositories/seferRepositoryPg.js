import { getPool } from '../db/pool.js';
import { getAICrowdednessPredictionsBatch } from '../services/crowding.js';
import { asBool } from '../utils.js';

const SQL = `
SELECT
  d.engellirampa AS durak_engelli,
  h.hatkodu,
  h.hatadi,
  a.kapasite,
  a.engelli AS arac_engelli,
  t.minutes_from_now
FROM f_sefer_template t
JOIN d_durak d ON d.sid = t.siddurak
JOIN d_hat h ON h.sid = t.sidhat
JOIN d_arac a ON a.sid = t.sid_arac
WHERE UPPER(TRIM(d.durakkodu)) = UPPER(TRIM($1))
  AND t.minutes_from_now >= 0
  AND t.minutes_from_now <= 60
ORDER BY t.minutes_from_now ASC
`;

/**
 * @param {string} durakKodu
 * @returns {Promise<import('../types.js').ApproachingBus[]>}
 */
export async function getApproachingBusesFromPg(durakKodu) {
  const pool = getPool();
  if (!pool) throw new Error('DATABASE_URL not configured');

  const { rows } = await pool.query(SQL, [durakKodu]);
  if (rows.length === 0) return [];

  const now = new Date();
  const rampOk = asBool(rows[0].durak_engelli);

  const trips = rows.map((r) => {
    const minutes = Number(r.minutes_from_now);
    const arrival = new Date(now.getTime() + minutes * 60_000);
    const kap = Math.max(1, Number(r.kapasite) || 1);
    return {
      hatKodu: r.hatkodu,
      hatAdi: r.hatadi,
      minutes,
      kap,
      arrival,
      aracEngelli: r.arac_engelli,
    };
  });

  const mlInputs = trips.map((x) => ({
    hatKodu: x.hatKodu,
    arrivalDate: x.arrival,
    kapasite: x.kap,
  }));
  const expectedList = await getAICrowdednessPredictionsBatch(mlInputs);

  const out = trips.map((x, i) => {
    const pred = expectedList[i] ?? { passengers: 0, fromMl: false };
    const expected = pred.passengers;
    const dolulukOrani = Math.min(100, Math.round((expected / x.kap) * 100));
    const engelliErisimi = rampOk && asBool(x.aracEngelli);
    return {
      hatKodu: x.hatKodu,
      hatAdi: x.hatAdi,
      kalanSureDk: x.minutes,
      dolulukOrani,
      engelliErisimi,
      beklenenYolcu: expected,
      mlTahmin: pred.fromMl,
      aracKapasitesi: x.kap,
      _sort: x.arrival.getTime(),
    };
  });

  return out.map(({ _sort, ...rest }) => rest);
}

const SQL_LIST_SUMMARIES = `
SELECT
  d.durakkodu,
  d.durakadi,
  d.engellirampa,
  d.enlem,
  d.boylam,
  sub.minutes_from_now AS en_yakin_dk,
  sub.hatkodu AS en_yakin_hat
FROM d_durak d
LEFT JOIN LATERAL (
  SELECT t.minutes_from_now, h.hatkodu
  FROM f_sefer_template t
  JOIN d_hat h ON h.sid = t.sidhat
  WHERE t.siddurak = d.sid AND t.minutes_from_now >= 0 AND t.minutes_from_now <= 60
  ORDER BY t.minutes_from_now ASC
  LIMIT 1
) sub ON true
ORDER BY d.sid
`;

/** @returns {Promise<Array<{ durakKodu: string, durakAdi: string, engelliErisimi: boolean, enYakinSeferDk: number | null, enYakinHatKodu: string | null }>>} */
export async function listPgStopSummaries() {
  const pool = getPool();
  if (!pool) throw new Error('DATABASE_URL not configured');
  const { rows } = await pool.query(SQL_LIST_SUMMARIES);
  return rows.map((r) => ({
    durakKodu: r.durakkodu,
    durakAdi: r.durakadi,
    engelliErisimi: asBool(r.engellirampa),
    enYakinSeferDk: r.en_yakin_dk != null ? Number(r.en_yakin_dk) : null,
    enYakinHatKodu: r.en_yakin_hat ?? null,
    enlem: r.enlem != null ? Number(r.enlem) : null,
    boylam: r.boylam != null ? Number(r.boylam) : null,
  }));
}

/**
 * @param {string} durakKodu
 * @returns {Promise<{ durakKodu: string, durakAdi: string, engelliErisimi: boolean } | null>}
 */
export async function getPgStopMeta(durakKodu) {
  const pool = getPool();
  if (!pool) throw new Error('DATABASE_URL not configured');
  const { rows } = await pool.query(
    `SELECT durakkodu, durakadi, engellirampa FROM d_durak WHERE UPPER(TRIM(durakkodu)) = UPPER(TRIM($1)) LIMIT 1`,
    [durakKodu],
  );
  if (!rows.length) return null;
  const r = rows[0];
  return {
    durakKodu: r.durakkodu,
    durakAdi: r.durakadi,
    engelliErisimi: asBool(r.engellirampa),
  };
}
