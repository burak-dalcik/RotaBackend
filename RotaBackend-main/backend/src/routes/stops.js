import { Router } from 'express';
import { getApproachingBusesForStop } from '../repositories/seferRepository.js';
import { getStopMeta, listStopSummaries } from '../repositories/stopRepository.js';

export const stopsRouter = Router();

stopsRouter.get('/', async (_req, res, next) => {
  try {
    res.json(await listStopSummaries());
  } catch (err) {
    next(err);
  }
});

stopsRouter.get('/:durakKodu/approaching-buses', async (req, res, next) => {
  try {
    const { durakKodu } = req.params;
    const data = await getApproachingBusesForStop(durakKodu);
    res.json(data);
  } catch (err) {
    next(err);
  }
});

stopsRouter.get('/:durakKodu', async (req, res, next) => {
  try {
    const { durakKodu } = req.params;
    const meta = await getStopMeta(durakKodu);
    if (!meta) {
      res.status(404).json({ error: 'Durak bulunamadı', durakKodu });
      return;
    }
    res.json(meta);
  } catch (err) {
    next(err);
  }
});
