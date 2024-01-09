### WordPress for Ali FunctionCompute

**Components:**
- Nginx and FastCGI Cache
- PHP-FPM and Opcache
- WordPress
- PHP Redis

**References:**
- [docker-library/wordpress](https://github.com/docker-library/wordpress/tree/ac65dab91d64f611e4fa89b5e92903e163d24572)
- [TrafeX/docker-php-nginx](https://github.com/TrafeX/docker-php-nginx/blob/master/README.md)
- [gioamato/stateless-wordpress](https://github.com/gioamato/stateless-wordpress/tree/master)
- [pingcap/wordpress-tidb-plugin](https://github.com/pingcap/wordpress-tidb-plugin)

## What WordPressOnFaas Achieves:

1. **TiDB Serverless Integration:**
   - Integrates TiDB Serverless for WordPress. Note: TiDB Serverless doesn't support the `utf8mb4_unicode_520_ci` collation; hence, `utf8mb4_unicode_ci` is used.

2. **Ali FunctionCompute Implementation:**
   - Leverages Ali FunctionCompute for WordPress, incorporating features like Health Check API, Startup Probe, Nginx FastCGI Cache, PHP-FPM, etc.

3. **wp-content on NAS:**
   - Mounts the `wp-content` directory to Network Attached Storage (NAS), providing shared and persistent storage.

4. **Efficient Cron Job Handling:**
   - Implements a real cron job in the container instead of using wp-cron. This optimization aims to reduce the cost associated with cold starts.


