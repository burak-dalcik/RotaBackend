import pickle, os

base = os.path.join(os.path.dirname(__file__), '..', 'ml')
model_path = os.path.join(base, 'rota_doluluk_modeli.pkl')
enc_path = os.path.join(base, 'rota_hat_encoder.pkl')

print('Loading model from', model_path)
m = pickle.load(open(model_path, 'rb'))
print('Model type:', type(m).__name__)

print('Loading encoder from', enc_path)
e = pickle.load(open(enc_path, 'rb'))
print('Encoder type:', type(e).__name__)
print('Encoder classes (first 5):', list(e.classes_[:5]))

# Test prediction: SAAT=14, HAFTASONU=0, RESMITATIL=0, HATKODU_ENCODED=5, KAPASITE=80
pred = m.predict([[14, 0, 0, 5, 80]])[0]
print('Test prediction (passengers):', pred)
print('SUCCESS - ML model works!')
