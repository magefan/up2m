# Tool For Installing Magento 2 on the Local Ubuntu Instance

## Requirements
PHP, Composer, MySQL, etc. according to Magento 2 system requirements

## Installation 
```
cd /var/www
wget https://github.com/magefan/up2m/archive/refs/heads/main.zip
unzip main.zip
mv up2m-main/ up2m
rm main.zip
cd up2m
cp conf.cfg_sample conf.cfg
gedit conf.cfg
```
## Usage

```
cd /var/www/up2m
./install.sh 2.4.6-p3
```
