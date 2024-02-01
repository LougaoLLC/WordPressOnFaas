### WordPress for Ali FunctionCompute

**Components:**
- Nginx and FastCGI Cache
- PHP-FPM and Opcache
- WordPress
- PHP Redis Extension

**References:**
- [docker-library/wordpress](https://github.com/docker-library/wordpress/tree/ac65dab91d64f611e4fa89b5e92903e163d24572)
- [TrafeX/docker-php-nginx](https://github.com/TrafeX/docker-php-nginx/blob/master/README.md)
- [gioamato/stateless-wordpress](https://github.com/gioamato/stateless-wordpress/tree/master)
- [pingcap/wordpress-tidb-plugin](https://github.com/pingcap/wordpress-tidb-plugin)

## What does this docker image do?

1. **TiDB Serverless Integration:**
   - Integrates TiDB Serverless for WordPress. Note: TiDB Serverless doesn't support the `utf8mb4_unicode_520_ci` collation; hence, `utf8mb4_unicode_ci` is used.

2. **Ali FunctionCompute Implementation:**
   - Leverages Ali FunctionCompute for WordPress, incorporating features like Health Check API, Startup Probe, Nginx FastCGI Cache, PHP-FPM, etc.

3. **wp-content on NAS:**
   - Mounts the `wp-content` directory to Network Attached Storage (NAS), providing shared and persistent storage.

4. **Efficient Cron Job Handling:**
   - Implements a real cron job in the container instead of using wp-cron. This optimization aims to reduce the cost associated with cold starts.

**Note:** If you use TiDB as the wordpress database, you need to set tidb_enable_noop_functions to 1.

```SET GLOBAL tidb_enable_noop_functions=1;```

See more: [20133](https://github.com/pingcap/tidb/issues/20133)

## How to use this image

ENV WORDPRESS_DB_NAME=""
ENV WORDPRESS_DB_USER=""
ENV WORDPRESS_DB_PASSWORD=""
ENV WORDPRESS_DB_HOST=""

```
docker run -p 8080:8080 -v /host/path:/data -e WORDPRESS_DB_NAME=dbname WORDPRESS_DB_USER=dbuser WORDPRESS_DB_PASSWORD=dbpwd WORDPRESS_DB_HOST=dbhost:port lougaocloud/serverless-wp:6.4.2-php8.3-fpm-alpine-v0
```

We mount the /host/path to /data in the container, so that the wp-content directory can be stored.

Then you can access WordPress at `http://localhost:8080` in a browser.
