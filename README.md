# wordpress4fc

Serverless WordPress For Ali FunctionCompute.

Include:

* apache
* php
* wordpress
* TiDB compatible

See more: 

* [docker-library/wordpress](https://github.com/docker-library/wordpress/tree/ac65dab91d64f611e4fa89b5e92903e163d24572)
* [gioamato/stateless-wordpress](https://github.com/gioamato/stateless-wordpress/tree/master)


Note:

If you use TiDB as the wordpress database, you need to set tidb_enable_noop_functions to 1.

```
SET GLOBAL tidb_enable_noop_functions=1;
```

See more: [#20133](https://github.com/pingcap/tidb/issues/20133)

