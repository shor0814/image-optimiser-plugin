<?php
/*
Plugin Name: CentminMod Image Optimiser
Plugin URI: https://github.com/shor0814/image-optimiser-plugin
Description: CentminMod Image Optimiser.  This WordPress plugin works with CentminMod to optimize all images in a given directory (and subs) and optionally creates webp format files
Author: Shawn Horton
Adapted from: George Liu (eva2000) centminmod.com
Version: 1.0
Author URI:
*/
$scriptlocation = "/usr/sbin";
$scriptname = "optimise-images-plugin.sh";
add_filter('wp_generate_attachment_metadata', 'optimise_upload_file');
function optimise_upload_file($meta)
{
    $path = wp_upload_dir(); // get upload directory
    $file = $path['basedir'].'/'.$meta['file']; // Get full size image

    $files[] = $file; // Set up an array of image size urls

    foreach ($meta['sizes'] as $size) {
        $files[] = $path['path'].'/'.$size['file'];
    }
//    $logname = $path['path'] . "/uploadfile.log";
//    unlink($logname);
//    $logfile = fopen($logname, "a");
    foreach ($files as $file) { // iterate through each image size
        $outname = $scriptlocation.$scriptname." optimise ".$file;
        execInBackground($outname,$output,$retval);
//        fwrite($logfile,$output);
    }
//    fclose($logfile);
    return $meta;
}

function execInBackground($cmd,$output,$retval) {
    if (substr(php_uname(), 0, 7) == "Windows"){
        pclose(popen("start /B ". $cmd, "r"));
    }
    else {
        exec($cmd . " 2>&1 &",$output,$retval);
    }
}

add_filter('wp_delete_file', 'optimise_delete_file');

function optimise_delete_file($file){
     if(file_exists($file.".webp")){
         @unlink($file.".webp");
     }
     return $file;
}
