FROM python:3.11-bullseye

ENV AIRFLOW_ENV=2.8.0

COPY  requirements/ requirements/

RUN pip install apache-airflow[celery]==$AIRFLOW_ENV --constraint requirements/constraints.txt
RUN pip install -r requirements/requirements.txt
    # pip install -r requirements/constraints.txt

COPY scripts/entrypoint.sh /entrypoint.sh
RUN ["chmod", "+x", "/entrypoint.sh"]

EXPOSE 6379 8080 5555 8793 5432

ENTRYPOINT ["/entrypoint.sh"]

HEALTHCHECK --interval=1m --timeout=2m --start-period=120s \
    CMD airflow jobs check --job-type SchedulerJob --allow-multiple --limit 10 

