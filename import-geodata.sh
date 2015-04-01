#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $DIR

MYSQL_DB=$(./project-env.php PROJECT_MYSQL_DATABASE)
MYSQL_USERNAME=$(./project-env.php PROJECT_MYSQL_USERNAME)
MYSQL_PASSWORD=$(./project-env.php PROJECT_MYSQL_PASSWORD)
MYSQL_TABLE="world_border"

cd $DIR/../gen

if [ ! -f "TM_WORLD_BORDERS-0.3.zip" ]; then
  curl -L -o TM_WORLD_BORDERS-0.3.zip http://thematicmapping.org/downloads/TM_WORLD_BORDERS-0.3.zip
  unzip TM_WORLD_BORDERS-0.3.zip
fi

if ! which ogr2ogr
then
  sudo add-apt-repository -y ppa:ubuntugis/ppa && \
  sudo apt-get update && \
  sudo apt-get install -y gdal-bin
fi

echo ogr2ogr -f MySQL MySQL:"$MYSQL_DB",user="$MYSQL_USERNAME",password="$MYSQL_PASSWORD" \
          -nln $MYSQL_TABLE -nlt MULTIPOLYGON \
          -update -overwrite \
          -lco ENGINE=MyISAM \
          -lco MYSQL_FID=ogr_fid -lco GEOMETRY_NAME=geometry \
          ./TM_WORLD_BORDERS-0.3.shp