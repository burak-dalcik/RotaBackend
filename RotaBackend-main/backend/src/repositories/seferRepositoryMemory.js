import { getAICrowdednessPredictionsBatch } from '../services/crowding.js';
import { asBool } from '../utils.js';

const D_DURAK = [
  { SID: 1, DURAKKODU: 'KAD-MRK', DURAKADI: 'Kadıköy Merkez', ENGELLIRAMPA: 'E', ENLEM: 40.9908, BOYLAM: 29.0237 },
  { SID: 2, DURAKKODU: 'BES-MYD', DURAKADI: 'Beşiktaş Meydan', ENGELLIRAMPA: 'E', ENLEM: 41.0425, BOYLAM: 29.0044 },
  { SID: 3, DURAKKODU: 'KAD-SHL', DURAKADI: 'Kadıköy Sahil', ENGELLIRAMPA: 'H', ENLEM: 40.9928, BOYLAM: 29.0185 },
];

const D_HAT = [
  { SID: 101, HATKODU: '19F', HATADI: 'FINDIKLI MAHALLESİ - YEDİTEPE ÜNİVERSİTESİ - KADIKÖY' },
  { SID: 102, HATKODU: '14ES', HATADI: 'ESENŞEHİR - ÜMRANİYE - KADIKÖY' },
  { SID: 103, HATKODU: '8A', HATADI: 'BATI ATAŞEHİR - KADIKÖY' },
  { SID: 104, HATKODU: 'MR1', HATADI: 'MARMARAY TRANSFER - KADIKÖY' },
  { SID: 105, HATKODU: '500T', HATADI: 'Tuzla - Cevizlibağ' },
];

const D_ARAC = [
  { SID: 201, KAPINO: 'A-1001', KAPASITE: 85, ENGELLI: 'E' },
  { SID: 202, KAPINO: 'A-1002', KAPASITE: 90, ENGELLI: 'E' },
  { SID: 203, KAPINO: 'A-1003', KAPASITE: 75, ENGELLI: 'H' },
  { SID: 204, KAPINO: 'A-1004', KAPASITE: 110, ENGELLI: 'E' },
];

const TRIP_TEMPLATES = [
  { SIDDURAK: 1, SIDHAT: 101, SIDARAC: 201, minutesFromNow: 8 },
  { SIDDURAK: 1, SIDHAT: 102, SIDARAC: 202, minutesFromNow: 12 },
  { SIDDURAK: 1, SIDHAT: 103, SIDARAC: 203, minutesFromNow: 24 },
  { SIDDURAK: 1, SIDHAT: 104, SIDARAC: 204, minutesFromNow: 40 },
  { SIDDURAK: 1, SIDHAT: 105, SIDARAC: 201, minutesFromNow: 55 },
  { SIDDURAK: 2, SIDHAT: 105, SIDARAC: 202, minutesFromNow: 6 },
  { SIDDURAK: 2, SIDHAT: 102, SIDARAC: 203, minutesFromNow: 18 },
  { SIDDURAK: 2, SIDHAT: 103, SIDARAC: 204, minutesFromNow: 35 },
  { SIDDURAK: 3, SIDHAT: 103, SIDARAC: 201, minutesFromNow: 9 },
  { SIDDURAK: 3, SIDHAT: 101, SIDARAC: 202, minutesFromNow: 22 },
  { SIDDURAK: 3, SIDHAT: 105, SIDARAC: 204, minutesFromNow: 48 },
];

function bySid(list, sid) {
  return list.find((r) => r.SID === sid);
}

/**
 * @param {string} durakKodu
 * @returns {Promise<import('../types.js').ApproachingBus[]>}
 */
export async function getApproachingBusesFromMemory(durakKodu) {
  const code = durakKodu.trim().toUpperCase();
  const durak = D_DURAK.find((d) => d.DURAKKODU.toUpperCase() === code);
  if (!durak) return [];

  const now = new Date();
  const rampOk = asBool(durak.ENGELLIRAMPA);

  const templates = TRIP_TEMPLATES.filter((t) => t.SIDDURAK === durak.SID).filter(
    (t) => t.minutesFromNow >= 0 && t.minutesFromNow <= 60,
  );

  const trips = [];
  for (const t of templates) {
    const hat = bySid(D_HAT, t.SIDHAT);
    const arac = bySid(D_ARAC, t.SIDARAC);
    if (!hat || !arac) continue;
    const arrival = new Date(now.getTime() + t.minutesFromNow * 60_000);
    const kap = Math.max(1, Number(arac.KAPASITE) || 1);
    trips.push({ t, hat, arac, arrival, kap });
  }

  const mlInputs = trips.map((x) => ({
    hatKodu: x.hat.HATKODU,
    arrivalDate: x.arrival,
    kapasite: x.kap,
  }));
  const expectedList = await getAICrowdednessPredictionsBatch(mlInputs);

  const rows = trips.map((x, i) => {
    const pred = expectedList[i] ?? { passengers: 0, fromMl: false };
    const expected = pred.passengers;
    const dolulukOrani = Math.min(100, Math.round((expected / x.kap) * 100));
    const engelliErisimi = rampOk && asBool(x.arac.ENGELLI);
    return {
      hatKodu: x.hat.HATKODU,
      hatAdi: x.hat.HATADI,
      kalanSureDk: x.t.minutesFromNow,
      dolulukOrani,
      engelliErisimi,
      beklenenYolcu: expected,
      mlTahmin: pred.fromMl,
      aracKapasitesi: x.kap,
      _sort: x.arrival.getTime(),
    };
  });

  rows.sort((a, b) => a._sort - b._sort);
  return rows.map(({ _sort, ...rest }) => rest);
}

/** @returns {Array<{ durakKodu: string, durakAdi: string, engelliErisimi: boolean, enYakinSeferDk: number | null, enYakinHatKodu: string | null }>} */
export function listMemoryStopSummaries() {
  return D_DURAK.map((d) => {
    const templates = TRIP_TEMPLATES.filter(
      (t) => t.SIDDURAK === d.SID && t.minutesFromNow >= 0 && t.minutesFromNow <= 60,
    );
    let enYakinSeferDk = null;
    let enYakinHatKodu = null;
    if (templates.length) {
      const best = templates.reduce((a, b) => (a.minutesFromNow <= b.minutesFromNow ? a : b));
      const hat = bySid(D_HAT, best.SIDHAT);
      enYakinSeferDk = best.minutesFromNow;
      enYakinHatKodu = hat?.HATKODU ?? null;
    }
    return {
      durakKodu: d.DURAKKODU,
      durakAdi: d.DURAKADI,
      engelliErisimi: asBool(d.ENGELLIRAMPA),
      enYakinSeferDk,
      enYakinHatKodu,
      enlem: d.ENLEM ?? null,
      boylam: d.BOYLAM ?? null,
    };
  });
}

/**
 * @param {string} durakKodu
 * @returns {{ durakKodu: string, durakAdi: string, engelliErisimi: boolean } | null}
 */
export function getMemoryStopMeta(durakKodu) {
  const code = durakKodu.trim().toUpperCase();
  const durak = D_DURAK.find((x) => x.DURAKKODU.toUpperCase() === code);
  if (!durak) return null;
  return {
    durakKodu: durak.DURAKKODU,
    durakAdi: durak.DURAKADI,
    engelliErisimi: asBool(durak.ENGELLIRAMPA),
  };
}
