<?php
/**
 * The base configuration for WordPress
 *
 * The wp-config.php creation script uses this file during the installation.
 * You don't have to use the web site, you can copy this file to "wp-config.php"
 * and fill in the values.
 *
 * This file contains the following configurations:
 *
 * * Database settings
 * * Secret keys
 * * Database table prefix
 * * ABSPATH
 *
 * @link https://wordpress.org/support/article/editing-wp-config-php/
 *
 * @package WordPress
 */

// ** Database settings - You can get this info from your web host ** //
/** The name of the database for WordPress */
define('DB_NAME', 'wordpress');

/** Database username */
define('DB_USER', 'wordpress');

/** Database password */
define( 'DB_PASSWORD', 'ke4zopuF9h' );

/** Database hostname */
define( 'DB_HOST', 'demo-db.dev-int.gridx.com' );

/** Database charset to use in creating database tables. */
define( 'DB_CHARSET', 'utf8' );

/** The database collate type. Don't change this if in doubt. */
define( 'DB_COLLATE', '' );

/**#@+
 * Authentication unique keys and salts.
 *
 * Change these to different unique phrases! You can generate these using
 * the {@link https://api.wordpress.org/secret-key/1.1/salt/ WordPress.org secret-key service}.
 *
 * You can change these at any point in time to invalidate all existing cookies.
 * This will force all users to have to log in again.
 *
 * @since 2.6.0
 */
define('AUTH_KEY',         'F%}~?f@.nw>O$+V`#@nK}x T*Z9kE^.TOLY2|8g>Up9Oi_@osQy]Fqgy%w3Z|L][');
define('SECURE_AUTH_KEY',  'LxY[OJ928v?[Nwbfou(QG|M-[ht.e_p!K;dI0hXgf_-),[T|wRm[|C>x#2jQ +M^');
define('LOGGED_IN_KEY',    '-+uIv2w-<URYoxi~IV;p>,H=B1DiS/4_E&O|;G;V+_fcu]k^Q2?)]L+O?hCb:UB7');
define('NONCE_KEY',        'G&8G y2!es;GU(Ce)F-=+362> N,M34[[H3e)h!QS4vO=.;?YA6Ix@h/-!;Z@(2Z');
define('AUTH_SALT',        'TedvwQjK~KH+jhEFU!u5l=+bLz&EdlS0l1>^x>Sn8N`lgn|,1]+!6(-l~9Kc?Nbb');
define('SECURE_AUTH_SALT', '%Hv`a)A,+=JFy.*>[pl0x^D=I?kI]wt[EM5_)uh8}Xk+}|yqr6w^Knx:--4v+>Z+');
define('LOGGED_IN_SALT',   'XQ_uVq#8 <> r>s>N]R0inbJ20 a8=J0ROtd7:?,:%;mlXj:.lYcS!p^D3VV.%f,');
define('NONCE_SALT',       '$2Fh!2rKb>Eo:N-Gwbu79QF-_AwF?5TBat/yAUh`D]Sza)d6/G5 ]r45;~=-XIfJ');
/**#@-*/

/**
 * WordPress database table prefix.
 *
 * You can have multiple installations in one database if you give each
 * a unique prefix. Only numbers, letters, and underscores please!
 */
$table_prefix = 'wp_';

/**
 * For developers: WordPress debugging mode.
 *
 * Change this to true to enable the display of notices during development.
 * It is strongly recommended that plugin and theme developers use WP_DEBUG
 * in their development environments.
 *
 * For information on other constants that can be used for debugging,
 * visit the documentation.
 *
 * @link https://wordpress.org/support/article/debugging-in-wordpress/
 */
define( 'WP_DEBUG', false );

/* Add any custom values between this line and the "stop editing" line. */



/* That's all, stop editing! Happy publishing. */

/** Absolute path to the WordPress directory. */
if ( ! defined( 'ABSPATH' ) ) {
        define( 'ABSPATH', __DIR__ . '/' );
}

/** Sets up WordPress vars and included files. */
require_once ABSPATH . 'wp-settings.php';
