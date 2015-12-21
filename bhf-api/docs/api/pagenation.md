## 分页信息
每次进行多条数据查询时，都会返回一个分页信息，存储在pagination字段。

```js

Demo:
{
    "items": [....],
    "pagination": {
        "pageSize": 11,
        "offset": 0,
        "pageIndex": 1,
        "recordCount": 4,
        "pageCount": 1
    }
}

Details:
"pagination":   Desc: 分页信息  DataType: JSON-Object
    "pageSize": 
      Desc：分页数据每页数据条数   DataType: integer  Extra: 和查询时的pageSize一致
    "offset":
        Desc: 可以忽略  DataType: integer
    "pageIndex":
        Desc: 当前页面数    DataType: integer
    "recordCount":
        Desc: 查询数据总条数    DataType: integer
    "pageCount":
        Desc: 查询数据分页总数目    DataType: integer
```