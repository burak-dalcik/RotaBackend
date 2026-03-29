Place your trained artefacts in this folder:

- `rota_doluluk_modeli.pkl` — XGBoost regressor
- `rota_hat_encoder.pkl` — `sklearn.preprocessing.LabelEncoder` for hat codes

Install Python deps once: `cd ../ml_service && pip install -r requirements.txt` (needs **scikit-learn**, **xgboost**, etc. to unpickle the models).

Start Node + ML together from `backend/`: `npm run dev:stack`, or run the bridge alone (see `ml_service/README.md`).
