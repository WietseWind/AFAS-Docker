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

if(isset($_GET["done"]) && isset($_POST['uploadtoken'])){
    $upload_handler = new UploadHandler(null, false);
    if(isset($_POST['uploadtoken']) && preg_match("@^[a-zA-Z0-9]{40}@", $_POST['uploadtoken'])){
        $files = [];
        try {
            $files = array_map(function($a){
                return ['name'=>$a->name,'size'=>$a->size,'url'=>$a->url];
            }, $upload_handler->get_file_objects());
        }
        catch (\Exception $e){
        }
        if(!empty($files)){
            $L_a_payload  = [ 'files' => $files, 'ssid' => session_id(), 'session' => $_SESSION ];
            $L_m_result   = @file_get_contents('https://afas-upload.nodum.io/json/callback', false, stream_context_create([ 'http' => [ 'method' => 'POST', 'header'  => 'Content-type: application/x-www-form-urlencoded', 'content' => http_build_query($L_a_payload) ] ]));
            $L_a_result   = @json_decode($L_m_result);
            if(isset($http_response_header[0]) && preg_match("@200 OK@", $http_response_header[0]) && $L_a_result && isset($L_a_result->location)){
                // echo "OK";
                @session_regenerate_id(true);
                header('Location: ' . $L_a_result->location);
            }else{
                // Todo: Error handling, Empty/Exception?
                header('Location: ../../?redirCause=CALLBACK_ERROR');
            }
        }else{
            // Todo: Error handling, Empty/Exception?
            header('Location: ../../?redirCause=EMPTY_OR_EXCEPTION');
        }
    }else{
        // Todo: Error handling, Security?
        header('Location: ../../?redirCause=SECURITY_VIOLATION');
    }
}else{
    $upload_handler = new UploadHandler();
}