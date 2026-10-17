FROM python:3.11-slim
RUN pip install --no-cache-dir dbt-core dbt-bigquery
WORKDIR /usr/app
COPY . .
ENTRYPOINT ["dbt"]
