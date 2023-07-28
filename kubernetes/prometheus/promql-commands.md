delete time series related to an instances 
```promql
curl -X POST -G 'http://localhost:9090/api/v1/admin/tsdb/delete_series?match[]={instance=~"https://yahoo.com"}
```
