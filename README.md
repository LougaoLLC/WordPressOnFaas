
# Serverless WordPress on Alibaba Cloud Function Compute

## Overview

This repository provides a specialized configuration for deploying WordPress on Alibaba Cloud Function Compute. Leveraging the power of serverless computing, this setup ensures scalable and efficient WordPress hosting. Key features include TiDB Serverless integration, Ali FunctionCompute implementation, and optimized cron job handling.

## Features

- **TiDB Serverless Integration:**
  - Integrates TiDB Serverless for WordPress, supporting `utf8mb4_unicode_ci` collation.

- **Ali FunctionCompute Implementation:**
  - Utilizes Alibaba Cloud Function Compute for WordPress deployment.
  - Features include Health Check API, Startup Probe, Nginx FastCGI Cache, PHP-FPM, etc.

- **Persistent Storage with NAS:**
  - Mounts the `wp-content` directory to Network Attached Storage (NAS), providing shared and persistent storage.

- **Efficient Cron Job Handling:**
  - Implements a real cron job in the container for optimized performance.

## Usage

### Environment Variables

```bash
ENV WORDPRESS_DB_NAME=""
ENV WORDPRESS_DB_USER=""
ENV WORDPRESS_DB_PASSWORD=""
ENV WORDPRESS_DB_HOST=""
```

### Docker Run Command

```bash
docker run -p 8080:8080 -v /host/path:/data -e WORDPRESS_DB_NAME=dbname WORDPRESS_DB_USER=dbuser WORDPRESS_DB_PASSWORD=dbpwd WORDPRESS_DB_HOST=dbhost:port lougaocloud/serverless-wp:6.4.2-php8.3-fpm-alpine-v0
```

Mount the `/host/path` to `/data` in the container for storing the `wp-content` directory.

Access WordPress at `http://localhost:8080` in a browser.

## Note

If using TiDB as the WordPress database, set `tidb_enable_noop_functions` to 1:

```sql
SET GLOBAL tidb_enable_noop_functions=1;
```

For more details, refer to [TiDB Issue 20133](https://github.com/pingcap/tidb/issues/20133).

## Deployment Considerations

To understand the reasons for choosing Alibaba Cloud Function Compute over AWS Lambda, please refer to the dedicated blog post: [Why Alibaba Cloud Function Compute?](https://www.serverless-wordpress.cloud/2024/01/08/why-not-aws-lambda/)

Feel free to explore the provided references for more information on the underlying Docker images and configurations.


