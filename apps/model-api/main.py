import os
import mlflow
from fastapi import FastAPI
from pydantic import BaseModel
from fastapi import HTTPException

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
    tracking_uri = os.getenv(
        "MLFLOW_TRACKING_URI",
        "http://localhost:5000"
    )
    mlflow.set_tracking_uri(tracking_uri)

    model_uri = f"models:/{MODEL_NAME}/1"
    return mlflow.pyfunc.load_model(model_uri)

#############startup####
@app.on_event("startup")
def startup_event():
    global _model
    try:
        _model = load_latest_model()
    except Exception as e:
        _model = None
        print(f"WARNING: Model not loaded at startup: {e}")

##############/healthz#########
@app.get("/healthz")
def healthz():
    return {"status": "ok", "model": MODEL_NAME}

@app.get("/readyz")
def readyz():
    if _model is None:
        raise HTTPException(
            status_code=503,
            detail="Model not loaded"
        )
    return {"status": "ready", "model": MODEL_NAME}

@app.post("/predict")
def predict(req: PredictRequest):
    global _model

    if _model is None:
        _model = load_latest_model()

    row = [[req.sepal_length, req.sepal_width, req.petal_length, req.petal_width]]
    pred = _model.predict(row)

    return {"prediction": int(pred[0])}