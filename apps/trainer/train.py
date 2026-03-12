import os
import mlflow
import mlflow.sklearn

from sklearn.datasets import load_iris
from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score
from sklearn.linear_model import LogisticRegression

MODEL_NAME = os.getenv("MODEL_NAME", "iris-classifier")

def main() -> None:
    tracking_uri = os.getenv("MLFLOW_TRACKING_URI", "http://localhost:5000")
    mlflow.set_tracking_uri(tracking_uri)
    mlflow.set_experiment("aidp-iris")

    iris = load_iris(as_frame=True)
    X = iris.data
    y = iris.target

    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.2, random_state=42, stratify=y
    )

    with mlflow.start_run() as run:
        model = LogisticRegression(max_iter=300)
        model.fit(X_train, y_train)

        preds = model.predict(X_test)
        acc = accuracy_score(y_test, preds)

        mlflow.log_metric("accuracy", float(acc))
        mlflow.log_param("model_type", "LogisticRegression")
        mlflow.log_param("max_iter", 300)

        # Log model into MLflow
        mlflow.sklearn.log_model(
            sk_model=model,
            artifact_path="model",
            registered_model_name=MODEL_NAME,
        )

        print(f"Run ID: {run.info.run_id}")
        print(f"Logged accuracy: {acc:.4f}")
        print(f"Registered/updated model: {MODEL_NAME}")

if __name__ == "__main__":
    main()