<?php
// setting cors
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type");


// DOWNLOAD FILE ---------------------------------------------------
/**
 * Godot access the url with "d" parameter, it contain the unique file name code
 */
if (isset($_REQUEST['d'])) {

    // receive image unique id from browser
    $file_name = $_REQUEST['d'] . '.png';
    $file_path = dirname(__FILE__) . '/' . $file_name;

    if (file_exists($file_path)) {

        // prepare image to download
        $im1 = imagecreatefrompng($file_path);
        imagesavealpha($im1, true);

        // download image
        header('Content-Disposition: Attachment;filename=' . $file_name);

        // show image in browser
        //header('Content-Type: image/png');
        imagepng($im1);
        imagedestroy($im1);

        // exclude file
        unlink($file_path);
        die();
    }

    // if image not found
    echo "file not exists";
    die();
}







// SAVE FILE -------------------------------------------------------
/**
 * Godot send to HTTP, we get the image and save in local server
 */

// request
$data_req = json_decode( file_get_contents('php://input') );

// file_name
$file_name = $data_req->uniquecode;

// prepare base64 to file
$data = 'data:image/png;base64,' . $data_req->image;

list($type, $data) = explode(';', $data);
list(, $data)      = explode(',', $data);
$data = base64_decode($data);

// save local
file_put_contents($file_name . '.png', $data);
