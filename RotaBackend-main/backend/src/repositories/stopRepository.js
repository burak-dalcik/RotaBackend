import { listMemoryStopSummaries, getMemoryStopMeta } from './seferRepositoryMemory.js';
import { listPgStopSummaries, getPgStopMeta } from './seferRepositoryPg.js';

/**
 * @returns {Promise<Array<{ durakKodu: string, durakAdi: string, engelliErisimi: boolean, enYakinSeferDk: number | null, enYakinHatKodu: string | null }>>}
 */
export async function listStopSummaries() {
  if (process.env.DATABASE_URL?.trim()) {
    try {
      return await listPgStopSummaries();
    } catch (e) {
      console.error('[stopRepository] PostgreSQL list failed, falling back to memory:', e?.message || e);
      return listMemoryStopSummaries();
    }
  }
  return listMemoryStopSummaries();
}

/**
 * @param {string} durakKodu
 * @returns {Promise<{ durakKodu: string, durakAdi: string, engelliErisimi: boolean } | null>}
 */
export async function getStopMeta(durakKodu) {
  if (process.env.DATABASE_URL?.trim()) {
    try {
      return await getPgStopMeta(durakKodu);
    } catch (e) {
      console.error('[stopRepository] PostgreSQL meta failed, falling back to memory:', e?.message || e);
      return getMemoryStopMeta(durakKodu);
    }
  }
  return getMemoryStopMeta(durakKodu);
}
