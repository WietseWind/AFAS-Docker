# AFAS-Docker

Docker Sample for AFAS (usage: file-upload environment)

## Environment

- Ubuntu 14.04 LTS CLI
- Apache 2.4
- PHP 7.0 + OpCache + Mongo-driver
- Webroot: `/var/www/nodum_projects/default`
- `index.php` is placed in the webroot.

## Sample scripts

#### Building the image

``` ./generate-image ```

#### Creating the container

``` ./generate-container ```

## Uploads

Uploads are saved in `/var/www/nodum_projects/default/server/php/files`. In this folder, a folder is created for each PHP Sessio ID. Uploaded files are placed in this folder. When images are uploaded, a subfolder for the thumbnails (generated using PHP GD) will be created.
