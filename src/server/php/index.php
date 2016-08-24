<?php
/*
 * jQuery File Upload Plugin PHP Example 5.14
 * https://github.com/blueimp/jQuery-File-Upload
 *
 * Copyright 2010, Sebastian Tschan
 * https://blueimp.net
 *
 * Licensed under the MIT license:
 * http://www.opensource.org/licenses/MIT
 */

if( (isset($_SERVER["HTTP_UPGRADE_INSECURE_REQUESTS"]) && $_SERVER["HTTP_UPGRADE_INSECURE_REQUESTS"] > 0) ||
    (isset($_SERVER['SERVER_ADDR']) &&
        (
            substr($_SERVER['SERVER_ADDR'],0,4) == '172.' ||
            substr($_SERVER['SERVER_ADDR'],0,4) == '192.' ||
            substr($_SERVER['SERVER_ADDR'],0,3) == '10.'
        )
    )
){
    $_SERVER['HTTPS']          = 'on';
    $_SERVER['REQUEST_SCHEME'] = 'https';
}

error_reporting(E_ALL | E_STRICT);

require('UploadHandler.php');

$upload_handler = new UploadHandler();
