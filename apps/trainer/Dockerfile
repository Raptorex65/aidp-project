FROM python:3.11-slim

WORKDIR /app

COPY apps/trainer/requirements.txt /app/requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

COPY apps/trainer/train.py /app/train.py

ENV PYTHONUNBUFFERED=1

CMD ["python", "train.py"]