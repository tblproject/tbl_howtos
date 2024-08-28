FROM apachesuperset.docker.scarf.sh/apache/superset:4.0.1
USER root
ADD init_duckdb ./init_duckdb/
RUN pip install -r init_duckdb/requirements.txt && \
    python init_duckdb/init_duckdb.py
USER superset
