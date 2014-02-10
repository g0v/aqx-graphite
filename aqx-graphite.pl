#!/usr/bin/env perl

use v5.14;
use strict;
use warnings;
use JSON::PP ();
use Net::Graphite;
use HTTP::Tiny;

## Debugging.
# $Net::Graphite::TEST = 1;

my $name_to_en = {
    "\x{5357}\x{6295}\x{7e23}.\x{5357}\x{6295}" => 'Nantou_County.Nantou',
    "\x{96f2}\x{6797}\x{7e23}.\x{9ea5}\x{5bee}" => 'Yunlin_County.Mailiao',
    "\x{5c4f}\x{6771}\x{7e23}.\x{6046}\x{6625}" => 'Pingdong_County.Hengchun_Township',
    "\x{9ad8}\x{96c4}\x{5e02}.\x{6797}\x{5712}" => 'Gaoxiong_City.Linyuan',
    "\x{65b0}\x{5317}\x{5e02}.\x{6c38}\x{548c}" => 'Xinbei_City.Yonghe',
    "\x{53f0}\x{4e2d}\x{5e02}.\x{6c99}\x{9e7f}" => 'Taizhong_City.Shalu',
    "\x{65b0}\x{7af9}\x{7e23}.\x{7af9}\x{6771}" => 'Xinzhu_County.Zhudong',
    "\x{9ad8}\x{96c4}\x{5e02}.\x{9cf3}\x{5c71}" => 'Gaoxiong_City.Fengshan',
    "\x{96f2}\x{6797}\x{7e23}.\x{53f0}\x{897f}" => 'Yunlin_County.Taixi',
    "\x{6843}\x{5712}\x{7e23}.\x{4e2d}\x{58e2}" => 'Taoyuan_County.Zhongli',
    "\x{57fa}\x{9686}\x{5e02}.\x{57fa}\x{9686}" => 'Jilong_City.Jilong_City',
    "\x{53f0}\x{5357}\x{5e02}.\x{53f0}\x{5357}" => 'Tainan_City.Tainan_County',
    "\x{96f2}\x{6797}\x{7e23}.\x{5d19}\x{80cc}" => 'Yunlin_County.Lunbei',
    "\x{82b1}\x{84ee}\x{7e23}.\x{82b1}\x{84ee}" => 'Hualian_County.Hualian',
    "\x{9023}\x{6c5f}\x{7e23}.\x{99ac}\x{7956}" => 'Lianjiang_County.Matsu_Village',
    "\x{5f70}\x{5316}\x{7e23}.\x{5f70}\x{5316}" => 'Zhanghua_County.Zhanghua',
    "\x{53f0}\x{4e2d}\x{5e02}.\x{5927}\x{91cc}" => 'Taizhong_City.Dali',
    "\x{5609}\x{7fa9}\x{7e23}.\x{65b0}\x{6e2f}" => 'Jiayi_County.Xingang',
    "\x{82d7}\x{6817}\x{7e23}.\x{982d}\x{4efd}" => 'Miaoli_County.Toufen',
    "\x{53f0}\x{5317}\x{5e02}.\x{842c}\x{83ef}" => 'Taibei_City.Wanhua',
    "\x{65b0}\x{5317}\x{5e02}.\x{65b0}\x{5e97}" => 'Xinbei_City.Xindian',
    "\x{65b0}\x{5317}\x{5e02}.\x{4e09}\x{91cd}" => 'Xinbei_City.Sanchong',
    "\x{65b0}\x{7af9}\x{7e23}.\x{6e56}\x{53e3}" => 'Xinzhu_County.Hukou',
    "\x{53f0}\x{5317}\x{5e02}.\x{5927}\x{540c}" => 'Taibei_City.Datong',
    "\x{9ad8}\x{96c4}\x{5e02}.\x{524d}\x{91d1}" => 'Gaoxiong_City.Qianjin',
    "\x{65b0}\x{5317}\x{5e02}.\x{6c50}\x{6b62}" => 'Xinbei_City.Xizhi',
    "\x{65b0}\x{5317}\x{5e02}.\x{842c}\x{91cc}" => 'Xinbei_City.Wanli',
    "\x{6843}\x{5712}\x{7e23}.\x{89c0}\x{97f3}" => 'Taoyuan_County.Guanyin',
    "\x{5f70}\x{5316}\x{7e23}.\x{4e8c}\x{6797}" => 'Zhanghua_County.Erlin',
    "\x{6843}\x{5712}\x{7e23}.\x{5927}\x{5712}" => 'Taoyuan_County.Dayuan',
    "\x{5609}\x{7fa9}\x{7e23}.\x{6734}\x{5b50}" => 'Jiayi_County.Puzi',
    "\x{6843}\x{5712}\x{7e23}.\x{5e73}\x{93ae}" => 'Taoyuan_County.Pingzhen',
    "\x{5357}\x{6295}\x{7e23}.\x{57d4}\x{91cc}" => 'Nantou_County.Puli',
    "\x{82d7}\x{6817}\x{7e23}.\x{4e09}\x{7fa9}" => 'Miaoli_County.Sanyi',
    "\x{53f0}\x{5317}\x{5e02}.\x{4e2d}\x{5c71}" => 'Taibei_City.Zhongshan',
    "\x{91d1}\x{9580}\x{7e23}.\x{91d1}\x{9580}" => 'Jinmen_County.Jinmen_County',
    "\x{53f0}\x{5357}\x{5e02}.\x{65b0}\x{71df}" => 'Tainan_City.Xinying',
    "\x{65b0}\x{5317}\x{5e02}.\x{571f}\x{57ce}" => 'Xinbei_City.Tucheng',
    "\x{53f0}\x{4e2d}\x{5e02}.\x{897f}\x{5c6f}" => 'Taizhong_City.Xitun',
    "\x{9ad8}\x{96c4}\x{5e02}.\x{7f8e}\x{6fc3}" => 'Gaoxiong_City.Meinong',
    "\x{5609}\x{7fa9}\x{5e02}.\x{5609}\x{7fa9}" => 'Jiayi_City.Jiayi',
    "\x{65b0}\x{5317}\x{5e02}.\x{6de1}\x{6c34}" => 'Xinbei_City.Danshui',
    "\x{5357}\x{6295}\x{7e23}.\x{7af9}\x{5c71}" => 'Nantou_County.Zhushan',
    "\x{5f70}\x{5316}\x{7e23}.\x{7dda}\x{897f}" => 'Zhanghua_County.Xianxi',
    "\x{9ad8}\x{96c4}\x{5e02}.\x{5de6}\x{71df}" => 'Gaoxiong_City.Zuoying',
    "\x{6f8e}\x{6e56}\x{7e23}.\x{99ac}\x{516c}" => 'Penghu_County.Magong_City',
    "\x{5c4f}\x{6771}\x{7e23}.\x{5c4f}\x{6771}" => 'Pingdong_County.Pingdong',
    "\x{9ad8}\x{96c4}\x{5e02}.\x{5927}\x{5bee}" => 'Gaoxiong_City.Daliao',
    "\x{65b0}\x{7af9}\x{5e02}.\x{65b0}\x{7af9}" => 'Xinzhu_City.Xinzhu',
    "\x{9ad8}\x{96c4}\x{5e02}.\x{5c0f}\x{6e2f}" => 'Gaoxiong_City.Xiaogang',
    "\x{65b0}\x{5317}\x{5e02}.\x{6797}\x{53e3}" => 'Xinbei_City.Linkou',
    "\x{53f0}\x{5317}\x{5e02}.\x{53e4}\x{4ead}" => 'Taibei_City.Guting',
    "\x{53f0}\x{5357}\x{5e02}.\x{5b89}\x{5357}" => 'Tainan_City.Annan',
    "\x{65b0}\x{5317}\x{5e02}.\x{83dc}\x{5bee}" => 'Xinbei_City.Cailiao',
    "\x{9ad8}\x{96c4}\x{5e02}.\x{4ec1}\x{6b66}" => 'Gaoxiong_City.Renwu',
    "\x{9ad8}\x{96c4}\x{5e02}.\x{524d}\x{93ae}" => 'Gaoxiong_City.Qianzhen',
    "\x{53f0}\x{5357}\x{5e02}.\x{5584}\x{5316}" => 'Tainan_City.Shanhua',
    "\x{9ad8}\x{96c4}\x{5e02}.\x{6a4b}\x{982d}" => 'Gaoxiong_City.Qiaotou',
    "\x{53f0}\x{5317}\x{5e02}.\x{58eb}\x{6797}" => 'Taibei_City.Shilin',
    "\x{65b0}\x{5317}\x{5e02}.\x{65b0}\x{838a}" => 'Xinbei_City.Xinzhuang',
    "\x{82d7}\x{6817}\x{7e23}.\x{82d7}\x{6817}" => 'Miaoli_County.Miaoli_County',
    "\x{96f2}\x{6797}\x{7e23}.\x{6597}\x{516d}" => 'Yunlin_County.Douliu',
    "\x{9ad8}\x{96c4}\x{5e02}.\x{6960}\x{6893}" => 'Gaoxiong_City.Nanzi',
    "\x{9ad8}\x{96c4}\x{5e02}.\x{5fa9}\x{8208}" => 'Gaoxiong_City.Fuxing',
    "\x{53f0}\x{6771}\x{7e23}.\x{95dc}\x{5c71}" => 'Taidong_County.Guanshan',
    "\x{65b0}\x{5317}\x{5e02}.\x{677f}\x{6a4b}" => 'Xinbei_City.Banqiao',
    "\x{53f0}\x{5317}\x{5e02}.\x{677e}\x{5c71}" => 'Taibei_City.Song_Mountain',
    "\x{53f0}\x{4e2d}\x{5e02}.\x{8c50}\x{539f}" => 'Taizhong_City.Fengyuan',
    "\x{6843}\x{5712}\x{7e23}.\x{6843}\x{5712}" => 'Taoyuan_County.Taoyuan',
    "\x{6843}\x{5712}\x{7e23}.\x{9f8d}\x{6f6d}" => 'Taoyuan_County.Longtan',
    "\x{53f0}\x{6771}\x{7e23}.\x{53f0}\x{6771}" => 'Taidong_County.Taidong',
    "\x{53f0}\x{5317}\x{5e02}.\x{967d}\x{660e}" => 'Taibei_City.Yangming',
    "\x{5b9c}\x{862d}\x{7e23}.\x{5b9c}\x{862d}" => 'Yilan_County.Yilan',
    "\x{5c4f}\x{6771}\x{7e23}.\x{6f6e}\x{5dde}" => 'Pingdong_County.Chaozhou',
    "\x{5b9c}\x{862d}\x{7e23}.\x{51ac}\x{5c71}" => 'Yilan_County.Dongshan',
    "\x{53f0}\x{4e2d}\x{5e02}.\x{5fe0}\x{660e}" => 'Taizhong_City.Zhongming'
};


# update hourly
my $url = "http://g0v-data-mirror.gugod.org/epa/aqx.json";

my $http = HTTP::Tiny->new;
my $res = $http->get($url);


die "Failed: $res->{status} $res->{reason}\n" unless $res->{success};

my $aqx = JSON::PP::decode_json($res->{content});


my @metric_data;
for (@$aqx) {
    $_->{pm25} = delete( $_->{'PM2.5'} );

    # say $_->{PublishTime};
    my $k = join(".", @{$_}{qw(County SiteName)});
    my $t = $name_to_en->{$k};

    unless ($t) {
        die "Failed to translate: $k";
    }

    for my $m (qw( PSI SO2 CO O3 PM10 pm25 NO2 WindSpeed WindDirec )) {
        if ($_->{$m} ne "") {
            push @metric_data, {
                path => "$t.$m",
                value => $_->{$m}
            };
        }
    }
}

my $graphite = Net::Graphite->new(fire_and_forget => 1);
$graphite->{trace} = 1;
for (@metric_data) {
    $_->{path} = lc($_->{path}) =~ s{\s+}{_}gr;
    $_->{path} = "epa.aqx." . $_->{path};

    $graphite->send(%$_);
}
