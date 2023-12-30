<?php
declare( strict_types=1 );

$preload_patterns = [
    "wp-includes/Text/Diff/Renderer.php",
    "wp-includes/Text/Diff/Renderer/inline.php",
    "wp-includes/SimplePie/**/*.php",
    "wp-includes/SimplePie/*.php",
    "wp-includes/Requests/**/*.php",
    "wp-includes/Requests/*.php",
    "wp-includes/**/class-*.php",
    "wp-includes/class-*.php",
];

$exclusions = [
    'wp-includes/class-simplepie.php',
    'wp-includes/SimplePie/File.php',
    'wp-includes/SimplePie/Core.php',
    'wp-includes/class-wp-simplepie-file.php',
    'wp-includes/class-snoopy.php',
    'wp-includes/class-json.php',
];

foreach ( $preload_patterns as $pattern ) {
    $files = glob( $pattern );

    foreach ( $files as $file ) {
        if ( ! in_array( $file, $exclusions, true ) ) {
            opcache_compile_file( $file );
        }
    }
}
