import duckdb

conn = duckdb.connect(':memory:')
conn.sql("INSTALL azure;")
conn.sql("LOAD azure;")
conn.sql("CREATE OR REPLACE PERSISTENT SECRET ( TYPE AZURE, CONNECTION_STRING 'DefaultEndpointsProtocol=https;AccountName=XXXXXXXX;AccountKey=XXXXXXXXXXXXXXX==;EndpointSuffix=core.windows.net');")
