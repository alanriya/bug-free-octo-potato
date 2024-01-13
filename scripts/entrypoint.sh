#!/bin/bash
TRY_LOOP="20"

wait_for_port() {
    local name="$1" host="$2" port="$3"
    local j=0
    while ! nc -z "$host" "$port" > /dev/null 2>&1 /dev/null; do
      j=$((j+1))
      if [$j -ge $TRY_LOOP ]; then
        echo >&2 "$(date) - $host:$port still not reachable, giving up"
        exit 1
      fi
      echo "$(date) waiting for $name... $j/$TRY_LOOP"
      SLEEP 5
    done
}

wait_for_redis(){
    if ["$AIRFLOW__CORE__EXECUTOR" == "CeleryExecutor" ]
        then 
            wait_for_port "Redis" "$REDIS_HOST" "$REDIS_PORT"
    fi
}

export REDIS_HOST=$2
export REDIS_PORT=6379
export POSTGRES_HOST=$2
export POSTGRES_PORT=6432
# airflow db init
# airflow db upgrade

case "$1" in 
    webserver)
        # wait_for_port "Postgres" "$POSTGRES_HOST" "$POSTGRES_PORT"
        # airflow db upgrade
        airflow db init
        airflow db migrate
        airflow users create --role Admin --username alan --password 123 --firstname Alan --lastname Lee --email alan@mail.com
        exec airflow webserver
        ;; 
    worker)
        # wait_for_port "Postgres" "$POSTGRES_HOST" "$POSTGRES_PORT"
        # ait_for_redis
        exec airflow celery $1
        ;;
    scheduler)
        # wait_for_port "Postgres" "$POSTGRES_HOST" "$POSTGRES_PORT"
        # wait_for_redis
        airflow db init
        airflow db migrate
        exec airflow scheduler
        ;;
    flower)
        # wait_for_port "Postgres" "$POSTGRES_HOST" "$POSTGRES_PORT"
        # wait_for_redis
        exec airflow $1
        ;;
esac

