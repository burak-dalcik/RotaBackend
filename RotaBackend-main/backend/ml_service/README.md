# Rota ML bridge (FastAPI)

## Setup

```bash
cd backend/ml_service
python -m venv .venv
.venv\Scripts\activate
pip install -r requirements.txt
```

Copy `rota_doluluk_modeli.pkl` and `rota_hat_encoder.pkl` into `backend/ml/`.

## Run

```bash
# from ml_service, with venv active
uvicorn app:app --host 0.0.0.0 --port 5042
```

Optional env:

- `ML_MODEL_DIR` — folder containing `.pkl` files (default: `../ml`)
- `ML_MODEL_FILE` / `ML_ENCODER_FILE` — override paths

## API

`GET /health` — bridge up and models loaded.

`POST /predict` — single row.

`POST /predict/batch` — preferred by Node API (one round-trip for all buses at a stop).

Batch body:

```json
{
  "items": [
    {
      "hatKodu": "500T",
      "kapasite": 85,
      "arrivalTime": "2026-03-29T16:30:00+03:00",
      "resmitatil": 0
    }
  ]
}
```

Response item: `{ "expectedPassengers": <float>, "hatKoduEncoded": <int>, "features": { ... } }`

Feature row order matches training: `SAAT`, `HAFTASONU`, `RESMITATIL`, `HATKODU_ENCODED`, `KAPASITE`.

`SAAT` / `HAFTASONU` are derived from `arrivalTime` in `Europe/Istanbul`.

## Run API + ML together (from `backend/`)

```bash
npm install
npm run dev:stack
```
