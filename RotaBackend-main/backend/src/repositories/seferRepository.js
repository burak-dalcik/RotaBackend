import { getApproachingBusesFromMemory } from './seferRepositoryMemory.js';
import { getApproachingBusesFromPg } from './seferRepositoryPg.js';

/**
 * PostgreSQL: set DATABASE_URL (e.g. Docker Compose). Otherwise in-memory seed.
 * @param {string} durakKodu
 * @returns {Promise<import('../types.js').ApproachingBus[]>}
 */
export async function getApproachingBusesForStop(durakKodu) {
  if (process.env.DATABASE_URL?.trim()) {
    try {
      return await getApproachingBusesFromPg(durakKodu);
    } catch (e) {
      console.error('[seferRepository] PostgreSQL failed, falling back to memory:', e?.message || e);
      return getApproachingBusesFromMemory(durakKodu);
    }
  }
  return getApproachingBusesFromMemory(durakKodu);
}
