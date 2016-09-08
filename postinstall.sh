#!/usr/bin/env bash

cd "$(dirname "$0")"

sed -ig "s/permalink)/permalink\.replace(\'github\.io\', \'ienav\.com\'))/g" ./node_modules/hexo-generator-baidu-sitemap/baidusitemap.ejs
