import os
import mlflow
from fastapi import FastAPI
from pydantic import BaseModel

# Create FastAPI app first
app = FastAPI(title="AIDP Model API", version="0.1.0")

MODEL_NAME = os.getenv("MODEL_NAME", "iris-classifier")

class PredictRequest(BaseModel):
    sepal_length: float
    sepal_width: float
    petal_length: float
    petal_width: float

_model = None

def load_latest_model():
    tracking_uri = os.getenv("MLFLOW_TRACKING_URI", "http://localhost:5000")
    mlflow.set_tracking_uri(tracking_uri)

    candidates = [
        f"models:/{MODEL_NAME}/Production",
        f"models:/{MODEL_NAME}/latest",
    ]

    last_err = None
    for uri in candidates:
        try:
            return mlflow.pyfunc.load_model(uri)
        except Exception as e:
            last_err = e

    raise RuntimeError(f"Could not load model '{MODEL_NAME}'. Last error: {last_err}")


@app.on_event("startup")
def startup_event():
    global _model
    try:
        _model = load_latest_model()
    except Exception as e:
        _model = None
        print(f"WARNING: Model not loaded at startup: {e}")


@app.get("/healthz")
def healthz():
    return {"status": "ok", "model": MODEL_NAME}


@app.post("/predict")
def predict(req: PredictRequest):
    global _model

    if _model is None:
        _model = load_latest_model()

    row = [[req.sepal_length, req.sepal_width, req.petal_length, req.petal_width]]
    pred = _model.predict(row)

    return {"prediction": int(pred[0])}