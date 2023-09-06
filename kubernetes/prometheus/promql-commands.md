delete time series related to an instances 
```promql
curl -X POST -G 'http://localhost:9090/api/v1/admin/tsdb/delete_series?match[]={instance=~"https://yahoo.com"}
```

Get all series - 
```
http://localhost:9090/api/v1/label/__name__/values
```

## Blackbox exporter

### HTTP response codes

Blackbox exporter
```promql
probe_http_status_code{target="google.com"}[5m]
```
