"""
Rota ML bridge: loads LabelEncoder + XGBoost regressor from backend/ml/*.pkl
and exposes POST /predict and POST /predict/batch for the Node backend.
"""
from __future__ import annotations

import os
import joblib
from contextlib import asynccontextmanager
from datetime import datetime
from pathlib import Path

import numpy as np
import pandas as pd
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field
from zoneinfo import ZoneInfo

FEATURE_ORDER = ["SAAT", "HAFTASONU", "RESMITATIL", "HATKODU_ENCODED", "KAPASITE"]
IST = ZoneInfo("Europe/Istanbul")

ML_DIR = Path(os.environ.get("ML_MODEL_DIR", Path(__file__).resolve().parent.parent / "ml"))
MODEL_FILE = Path(os.environ.get("ML_MODEL_FILE", ML_DIR / "rota_doluluk_modeli.pkl"))
ENCODER_FILE = Path(os.environ.get("ML_ENCODER_FILE", ML_DIR / "rota_hat_encoder.pkl"))

hat_encoder = None
model = None
_load_error: str | None = None


def _load_pickle(path: Path):
    return joblib.load(path)


@asynccontextmanager
async def lifespan(app: FastAPI):
    global hat_encoder, model, _load_error
    hat_encoder = None
    model = None
    _load_error = None
    strict = os.environ.get("ML_STRICT_STARTUP", "").strip().lower() in ("1", "true", "yes")
    try:
        if not ENCODER_FILE.is_file():
            raise RuntimeError(f"Encoder not found: {ENCODER_FILE}")
        if not MODEL_FILE.is_file():
            raise RuntimeError(f"Model not found: {MODEL_FILE}")
        hat_encoder = _load_pickle(ENCODER_FILE)
        model = _load_pickle(MODEL_FILE)
    except Exception as e:
        _load_error = f"{type(e).__name__}: {e}"
        print(f"[ml] model load failed: {_load_error}", flush=True)
        if strict:
            raise
    try:
        yield
    finally:
        hat_encoder = None
        model = None


app = FastAPI(title="Rota ML Bridge", version="1.0.0", lifespan=lifespan)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


class PredictRequest(BaseModel):
    hatKodu: str = Field(..., min_length=1, description="Raw route code, e.g. 500T")
    kapasite: int = Field(..., gt=0)
    arrivalTime: datetime = Field(..., description="ISO 8601 arrival time at stop")
    resmitatil: int = Field(0, ge=0, le=1)


class PredictResponse(BaseModel):
    expectedPassengers: float
    hatKoduEncoded: int
    features: dict


class BatchPredictRequest(BaseModel):
    items: list[PredictRequest] = Field(..., min_length=1)


class BatchPredictResponse(BaseModel):
    results: list[PredictResponse]


def _encode_hat(hat_kodu: str) -> int:
    key = hat_kodu.strip().upper()
    classes = getattr(hat_encoder, "classes_", None)
    if classes is not None and key not in classes:
        return 0
    try:
        return int(hat_encoder.transform([key])[0])
    except Exception:
        return 0


def _feature_dict(req: PredictRequest) -> dict:
    dt = req.arrivalTime
    if dt.tzinfo is None:
        dt = dt.replace(tzinfo=IST)
    local = dt.astimezone(IST)
    saat = int(local.hour)
    haftasonu = 1 if local.weekday() >= 5 else 0
    hat_enc = _encode_hat(req.hatKodu)
    return {
        "SAAT": saat,
        "HAFTASONU": haftasonu,
        "RESMITATIL": int(req.resmitatil),
        "HATKODU_ENCODED": hat_enc,
        "KAPASITE": int(req.kapasite),
    }


def _dataframe_from_items(items: list[PredictRequest]) -> tuple[pd.DataFrame, list[dict]]:
    dicts = [_feature_dict(r) for r in items]
    df = pd.DataFrame(dicts, columns=FEATURE_ORDER)
    return df, dicts


@app.get("/health")
def health():
    """Her zaman HTTP 200 — Docker healthcheck için süreç ayakta mı kontrolü."""
    loaded = model is not None and hat_encoder is not None
    out: dict = {"ok": True, "ml_loaded": loaded}
    if _load_error and not loaded:
        out["load_error"] = _load_error[:800]
    return out


@app.post("/predict", response_model=PredictResponse)
def predict(req: PredictRequest):
    if model is None or hat_encoder is None:
        raise HTTPException(503, "Model not loaded")
    try:
        X, rows = _dataframe_from_items([req])
        raw = model.predict(X)
        pred = float(np.asarray(raw).ravel()[0])
        if not np.isfinite(pred):
            pred = 0.0
        pred = max(0.0, pred)
        feat = rows[0]
        return PredictResponse(
            expectedPassengers=pred,
            hatKoduEncoded=int(feat["HATKODU_ENCODED"]),
            features=feat,
        )
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(500, detail=str(e)) from e


@app.post("/predict/batch", response_model=BatchPredictResponse)
def predict_batch(body: BatchPredictRequest):
    if model is None or hat_encoder is None:
        raise HTTPException(503, "Model not loaded")
    try:
        X, rows = _dataframe_from_items(body.items)
        raw = model.predict(X)
        arr = np.asarray(raw).ravel()
        out: list[PredictResponse] = []
        for i, feat in enumerate(rows):
            pred = float(arr[i]) if i < len(arr) else float(arr[-1])
            if not np.isfinite(pred):
                pred = 0.0
            pred = max(0.0, pred)
            out.append(
                PredictResponse(
                    expectedPassengers=pred,
                    hatKoduEncoded=int(feat["HATKODU_ENCODED"]),
                    features=feat,
                )
            )
        return BatchPredictResponse(results=out)
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(500, detail=str(e)) from e
