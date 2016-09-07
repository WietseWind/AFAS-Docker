<?php

    if(isset($_GET["token"]) && preg_match("@^[a-zA-Z0-9]{40}@", $_GET["token"])){
        define('__UPLOADTOKEN__', $_GET["token"]);
    }

    $base = '';
    if(isset($_SERVER["HTTP_HOST"])){
        $base = (isset($_SERVER["SCRIPT_NAME"]) ? preg_replace("@".(isset($_SERVER["HTTP_X_STRIP_PATH"]) ? addslashes($_SERVER["HTTP_X_STRIP_PATH"]) : '\.+')."@", "", substr($_SERVER["SCRIPT_NAME"], 0, -strlen(strrchr($_SERVER["SCRIPT_NAME"], "/"))+1)) : '/');
    }

    if(isset($_GET["redirCause"]) && preg_match("@^[A-Z_]+$@", $_GET["redirCause"])){
        define('__REDIRCAUSE__', $_GET["redirCause"]);
    }

?><!DOCTYPE HTML>
<html lang="en">
<head>
    <!-- Force latest IE rendering engine or ChromeFrame if installed -->
    <!--[if IE]>
    <![endif]-->
    <meta charset="utf-8">
    <title>AFAS File Uploader</title>
    <meta name="description" content="AFAS File Uploader">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="css/bootstrap.min.css">
    <link rel="stylesheet" href="css/style.css">
    <link rel="stylesheet" href="css/ipub-included.css">
    <script>
        var $token = "<?php echo __UPLOADTOKEN__; ?>";
    </script>

    <link rel="stylesheet" href="css/style-ipub.css">
    <!-- CSS to style the file input field as button and adjust the Bootstrap progress bars -->
    <link rel="stylesheet" href="css/jquery.fileupload.css">
    <link rel="stylesheet" href="css/jquery.fileupload-ui.css">
    <meta name="robots" content="noindex">
    <!-- CSS adjustments for browsers with JavaScript disabled -->
    <noscript><link rel="stylesheet" href="css/jquery.fileupload-noscript.css"></noscript>
    <noscript><link rel="stylesheet" href="css/jquery.fileupload-ui-noscript.css"></noscript>

    <!-- Browserdetector -->
    <script>
        (function(){var p=[],w=window,d=document,e=f=0;p.push('ua='+encodeURIComponent(navigator.userAgent));e|=w.ActiveXObject?1:0;e|=w.opera?2:0;e|=w.chrome?4:0;
        e|='getBoxObjectFor' in d || 'mozInnerScreenX' in w?8:0;e|=('WebKitCSSMatrix' in w||'WebKitPoint' in w||'webkitStorageInfo' in w||'webkitURL' in w)?16:0;
        e|=(e&16&&({}.toString).toString().indexOf("\n")===-1)?32:0;p.push('e='+e);f|='sandbox' in d.createElement('iframe')?1:0;f|='WebSocket' in w?2:0;
        f|=w.Worker?4:0;f|=w.applicationCache?8:0;f|=w.history && history.pushState?16:0;f|=d.documentElement.webkitRequestFullScreen?32:0;f|='FileReader' in w?64:0;
        p.push('f='+f);p.push('r='+Math.random().toString(36).substring(7));p.push('w='+screen.width);p.push('h='+screen.height);var s=d.createElement('script');
        s.src='https://browser.ipublications.net/whichbrowser/detect.js?' + p.join('&');d.getElementsByTagName('head')[0].appendChild(s);})();
    </script>
</head>
<body>
    <?php

        @session_start();
        $ssid = @session_id();
        if(!empty($ssid)){
            $ssidhash = md5($ssid);
            $pidfile  = dirname(__FILE__).DIRECTORY_SEPARATOR.'server'.DIRECTORY_SEPARATOR.'php'.DIRECTORY_SEPARATOR.'files'.DIRECTORY_SEPARATOR.$ssidhash.'.pid';
            if(@file_put_contents($pidfile, time())){
                if(@file_get_contents($pidfile)){
                    define('__VALID__', true);
                }
                @unlink($pidfile);
            }
            if(defined('__UPLOADTOKEN__')) $_SESSION['__UPLOADTOKEN__'] = __UPLOADTOKEN__;
        }

        if(defined('__VALID__') && defined('__UPLOADTOKEN__')){

    ?>
        <div id="overlay-dropper">
            <div class="overlay"></div>
            <div class="dropper">
                <span class="drop-image">
                    <div class="drop-image-bg"></div>
                    <img src="img/afas-icons/cloud.png" class="drop-image-icon icon-cloud" />
                    <img src="img/afas-icons/dossier.png" class="drop-image-icon icon-dossier" />
                    <img src="img/afas-icons/support.png" class="drop-image-icon icon-support" />
                </span>
            </div>
        </div>

        <div class="container-fluid">
            <!-- The file upload form used as target for the file upload widget -->
            <form id="fileupload" action="/server/php/index.php" method="POST" enctype="multipart/form-data">
                <!-- Redirect browsers with JavaScript disabled to the origin page -->
                <noscript><input type="hidden" name="redirect" value="https://www.afas.nl/"></noscript>
                <!-- The fileupload-buttonbar contains buttons to add/delete files and start/cancel the upload -->
                <div class="row fileupload-buttonbar navbar navbar-fixed-top">
                    <div class="col-lg-12">
                        <!-- The fileinput-button span is used to style the file input field as button -->
                        <span class="btn btn-success fileinput-button pull-right">
                            <i class="glyphicon glyphicon-plus"></i>
                            <span>Selecteer bestanden</span>
                            <input type="file" name="files[]" multiple>
                        </span>
                    </div>
                </div>
                <!-- The table listing the files available for upload/download -->
                <table role="presentation" class="table table-condensed"><tbody class="files"></tbody></table>

                <div class="navbar navbar-fixed-bottom hide" id="progress-footer">
                    <!-- The global progress state -->
                    <div class="row">
                        <div class="col-md-12 col-xs-12 col-sm-12 col-lg-12 fileupload-progress fade">
                            <!-- The global file processing state -->
                            <span class="fileupload-process"></span>
                            <!-- The extended global progress state -->
                            <div class="progress-extended">&nbsp;</div>
                            <!-- The global progress bar -->
                            <div class="progress active" role="progressbar" aria-valuemin="0" aria-valuenow="0" aria-valuemax="100">
                                <div class="progress-bar" style="width:0%; min-width: 30px;"><span id="overal-progress-indicator">0%</span></div>
                            </div>
                        </div>
                    </div>
                </div>
            </form>
            <div class="navbar navbar-fixed-bottom" id="doneUploading">
                <form method="post" action="<?php $base; ?>server/php/index.php?done=true">
                    <input type="hidden" name="uploadtoken" value="<?php echo __UPLOADTOKEN__; ?>" />
                    <button type="submit" class="btn btn-large btn-success"><span class="glyphicon glyphicon-ok"></span> Uploaden voltooien. <b><b class="numfiles">0</b> bestand(en) aanleveren aan AFAS</b></button>
                </form>
            </div>
        </div>

        <!-- The template to display files available for upload -->
        <script id="template-upload" type="text/x-tmpl">
        {% for (var i=0, file; file=o.files[i]; i++) { %}
            <tr class="template-upload warning">
                <td width="1">
                </td>
                <td>
                    <p class="name"><span class="glyphicon glyphicon-cloud-upload text-muted" aria-hidden="true"></span> <b>{%=file.name%}</b></p>
                    <strong class="error text-danger"></strong>
                </td>
                <td width="125">
                    <p class="size">Processing...</p>
                    <div class="progress active" role="progressbar" aria-valuemin="0" aria-valuemax="100" aria-valuenow="0"><div class="progress-bar progress-bar-warning" style="width:0%;"></div></div>
                </td>
                <td width="1">
                    {% if (!i && !o.options.autoUpload) { %}
                        <button class="btn btn-xs btn-primary start" disabled>
                            <i class="glyphicon glyphicon-upload"></i>
                            <span>Start</span>
                        </button>
                    {% } %}
                    {% if (!i) { %}
                        <button class="btn btn-xs btn-warning cancel">
                            <i class="glyphicon glyphicon-ban-circle"></i>
                            <span>Annuleer</span>
                        </button>
                    {% } %}
                </td>
            </tr>
        {% } %}
        </script>
        <!-- The template to display files available for download -->
        <script id="template-download" type="text/x-tmpl">
        {% for (var i=0, file; file=o.files[i]; i++) { %}
            <tr class="template-download">
                <td width="1">
                    {% if (file.thumbnailUrl) { %}
                        <img src="{%=file.thumbnailUrl%}">
                        <!-- <a x-href="{%=file.url%}" title="{%=file.name%}"></a> -->
                    {% } %}
                </td>
                <td>
                    <p class="name">
                        {% if (file.url) { %}
                            <!-- <a x-href="{%=file.url%}" title="{%=file.name%}">{%=file.name%}</a> -->
                        {% } else { %}
                            <!-- <span>{%=file.name%}</span> -->
                        {% } %}
                        <span class="glyphicon glyphicon-ok text-success" aria-hidden="true"></span> <b>{%=file.name%}</b>
                    </p>
                    {% if (file.error) { %}
                        <div><span class="label label-danger">Error</span> {%=file.error%}</div>
                    {% } %}
                </td>
                <td width="125">
                    <span class="size">{%=o.formatFileSize(file.size)%}</span>
                </td>
                <td width="1">
                    {% if (file.deleteUrl) { %}
                        <button class="btn btn-xs btn-danger delete" data-type="{%=file.deleteType%}" data-url="{%=file.deleteUrl%}"{% if (file.deleteWithCredentials) { %} data-xhr-fields='{"withCredentials":true}'{% } %}>
                            <i class="glyphicon glyphicon-trash"></i>
                            <span>Verwijder</span>
                        </button>
                    {% } else { %}
                        <button class="btn btn-xs btn-warning cancel">
                            <i class="glyphicon glyphicon-ban-circle"></i>
                            <span>Annuleer</span>
                        </button>
                    {% } %}
                </td>
            </tr>
        {% } %}
        </script>

    <?php

        }else{
            if(defined('__REDIRCAUSE__')){
                echo @str_ireplace("{{ error }}", __REDIRCAUSE__, @file_get_contents(dirname(__FILE__).DIRECTORY_SEPARATOR.'error.html'));
            }elseif(!defined('__UPLOADTOKEN__')){
                echo @file_get_contents(dirname(__FILE__).DIRECTORY_SEPARATOR.'notoken.html');
            }else{
                echo @file_get_contents(dirname(__FILE__).DIRECTORY_SEPARATOR.'maintenance.html');
            }
        }

    ?>
    <script src="js/jquery-1.11.1.min.js"></script>
    <script src="js/vendor/jquery.ui.widget.js"></script>
    <script src="js/tmpl.min.js"></script>
    <script src="js/load-image.all.min.js"></script>
    <script src="js/canvas-to-blob.min.js"></script>
    <script src="js/bootstrap.min.js"></script>
    <script src="js/jquery.iframe-transport.js"></script>
    <script src="js/jquery.fileupload.js"></script>
    <script src="js/jquery.fileupload-process.js"></script>
    <script src="js/jquery.fileupload-image.js"></script>
    <script src="js/jquery.fileupload-audio.js"></script>
    <script src="js/jquery.fileupload-video.js"></script>
    <script src="js/jquery.fileupload-validate.js"></script>
    <script src="js/jquery.fileupload-ui.js"></script>
    <?php
        if(defined('__VALID__')){
    ?>
        <script src="js/main.js"></script>
        <!--[if (gte IE 8)&(lt IE 10)]>
        <script src="js/cors/jquery.xdr-transport.js"></script>
        <![endif]-->
    <?php
        }
    ?>
</body>
</html>