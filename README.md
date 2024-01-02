# wordpress4fc

WordPress For Ali FunctionCompute.

Include:

* supervisord
* nginx
* php-fpm
* wordpress

See more: 

* [docker-library/wordpress](https://github.com/docker-library/wordpress/tree/ac65dab91d64f611e4fa89b5e92903e163d24572)
* [TrafeX/docker-php-nginx](https://github.com/TrafeX/docker-php-nginx/blob/master/README.md)
* [gioamato/stateless-wordpress](https://github.com/gioamato/stateless-wordpress/tree/master)

## What does it do?

* TiDB Serverless for WordPress (TiDB Serverless does not support `utf8mb4_unicode_520_ci` collation, so we use `utf8mb4_unicode_ci` instead)
* Ali FunctionCompute for WordPress (Health check api, Startup Probe, Nginx FastCGI Cache, PHP-FPM, etc.)
* XMLRPC disabled (Optional, it's disabled by default)
* wp-content mounted to NAS

