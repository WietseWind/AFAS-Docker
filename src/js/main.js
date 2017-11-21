/*
 * jQuery File Upload Plugin JS Example 8.9.1
 * https://github.com/blueimp/jQuery-File-Upload
 *
 * Copyright 2010, Sebastian Tschan
 * https://blueimp.net
 *
 * Licensed under the MIT license:
 * http://www.opensource.org/licenses/MIT
 */

/* global $, window */

$(function () {
    'use strict';

    var dropzoneTimeout,Browser;
    var progressCleared = 0,
        $backendUrl     = 'server/php/index.php/token:' + $token + '/';

    $(window).load(function(){
        Browser = new WhichBrowser();
        if(Browser.browser.name == 'Internet Explorer' && Browser.browser.version.major < 10){
            $("body").addClass('ielt10');
        }
    });

    var $_fu = $('#fileupload').fileupload({
        // Uncomment the following to send cross-domain cookies:
        // xhrFields: {withCredentials: true},

        maxRetries  : 100,
        retryTimeout: 750,
        maxChunkSize: 5000000,
        autoUpload  : true,
        url         : $backendUrl,
        acceptFileTypes: /\.(zip|rar|7z)/,

        add: function (e, data) {
            var that = this;
            $.getJSON($backendUrl, {file: data.files[0].name}, function (result) {
                var file = result.file;
                data.uploadedBytes = file && file.size;
                $.blueimp.fileupload.prototype.options.add.call(that, e, data);
            });
         },
         dragover : function(e){
            $("#overlay-dropper").addClass('goAnimate');

            clearTimeout(dropzoneTimeout);
            dropzoneTimeout = setTimeout(function(){
                $("#overlay-dropper").removeClass('goAnimate');
            }, 250);
            return;
         },
         drop : function(e){
            $("#overlay-dropper").removeClass('goAnimate');
            $("#doneUploading").removeClass('visible').hide()
            countFilesActivateButton()
            return;
         },
         submit : function(e, data){
            if(!$("body").hasClass("ielt10")){
                $("#progress-footer").removeClass('hide');
                $("body").addClass('isuploading');
                isUploading();
            }
            if(progressCleared > 0){
                var uploadPos = $("tbody.files tr:last");
                if(uploadPos.length > 0){
                    $('body,html').stop().animate({scrollTop:uploadPos.offset().top},200);
                }
            }
            return;
         },
         destroyed: function(e, data){
            countFilesActivateButton(false)

         },
         send : function(e, data){
            return;
         },
         always : function(e, data){
            setTimeout(function(){
                if(!$(".fileupload-progress").hasClass('in')){
                    $("#progress-footer").addClass('hide');
                    $("body").removeClass('isuploading');
                    doneUploading();
                    countFilesActivateButton(true)
                    progressCleared++;
                }
            }, 100);

            return;
         },
         fail: function (e, data) {
            // jQuery Widget Factory uses "namespace-widgetname" since version 1.10.0:
            var fu = $(this).data('blueimp-fileupload') || $(this).data('fileupload'),
                retries = data.context.data('retries') || 0,
                retry = function () {
                    $.getJSON($backendUrl, {file: data.files[0].name, retry: true})
                        .done(function (result) {
                            var file = result.file;
                            data.uploadedBytes = file && file.size;
                            // clear the previous data:
                            data.data = null;
                            data.submit();
                        })
                        .fail(function () {
                            fu._trigger('fail', e, data);
                        });
                };
            if (data.errorThrown !== 'abort' &&
                    data.uploadedBytes < data.files[0].size &&
                    retries < fu.options.maxRetries) {
                retries += 1;
                data.context.data('retries', retries);
                window.setTimeout(retry, retries * fu.options.retryTimeout);
                return;
            }
            data.context.removeData('retries');
            $.blueimp.fileupload.prototype.options.fail.call(this, e, data);
        }
    });

    $('#fileupload').fileupload(
        'option',
        'redirect',
        window.location.href.replace(
            /\/[^\/]*$/,
            '/cors/result.html?%s'
        )
    );

    // Load existing files:
    $('#fileupload').addClass('fileupload-processing');
    $.ajax({
        // Uncomment the following to send cross-domain cookies:
        //xhrFields: {withCredentials: true},
        url: $('#fileupload').fileupload('option', 'url'),
        dataType: 'json',
        context: $('#fileupload')[0]
    }).always(function () {
        $(this).removeClass('fileupload-processing');
    }).done(function (result) {
        $(this).fileupload('option', 'done').call(this, $.Event('done'), {result: result});
        countFilesActivateButton(true)
    });

});

var countFilesActivateButton = function(fade){
    var rfl = $('p.name').length - $('td>strong.error.text-danger').length
    $("#doneUploading b.numfiles").text(rfl)
    if(rfl > 0){
        setTimeout(function(){
            $("#doneUploading").addClass('visible').show();
        }, 500);
    }else{
        $("#doneUploading").hide().removeClass('visible')
    }
}

function isUploading(){
    $("#doneUploading").hide()
}

function doneUploading(){
    $("#doneUploading").show()
}
