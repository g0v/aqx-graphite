use v5.14;
use utf8;
use strict;
use Text::CSV;
use JSON::PP;

binmode STDOUT, ":utf8";
binmode STDERR, ":utf8";


my %name_trans = ();

open my $fh, "<:utf8", "county_h.utf8.csv";

my $csv = Text::CSV->new({ binary => 1 });
while (my $row = $csv->getline($fh)) {
    my $k = $row->[1];
    $name_trans{ $k } = $row->[2];
    $k =~ s/臺/台/g;
    $name_trans{ $k } = $row->[2];

    $k =~ s/台/臺/g;
    $name_trans{ $k } = $row->[2];

    # $k =~ s/.$//g;
    # $name_trans{ $k } = $row->[1];
}
close($fh);

my @names = qw(
    南投縣.南投
    南投縣.埔里
    南投縣.竹山
    台中市.大里
    台中市.忠明
    台中市.沙鹿
    台中市.西屯
    台中市.豐原
    台北市.中山
    台北市.古亭
    台北市.士林
    台北市.大同
    台北市.松山
    台北市.萬華
    台北市.陽明
    台南市.台南
    台南市.善化
    台南市.安南
    台南市.新營
    台東縣.台東
    台東縣.關山
    嘉義市.嘉義
    嘉義縣.新港
    嘉義縣.朴子
    基隆市.基隆
    宜蘭縣.冬山
    宜蘭縣.宜蘭
    屏東縣.屏東
    屏東縣.恆春
    屏東縣.潮州
    彰化縣.二林
    彰化縣.彰化
    彰化縣.線西
    新北市.三重
    新北市.土城
    新北市.新店
    新北市.新莊
    新北市.板橋
    新北市.林口
    新北市.永和
    新北市.汐止
    新北市.淡水
    新北市.菜寮
    新北市.萬里
    新竹市.新竹
    新竹縣.湖口
    新竹縣.竹東
    桃園縣.中壢
    桃園縣.大園
    桃園縣.平鎮
    桃園縣.桃園
    桃園縣.觀音
    桃園縣.龍潭
    澎湖縣.馬公
    花蓮縣.花蓮
    苗栗縣.三義
    苗栗縣.苗栗
    苗栗縣.頭份
    連江縣.馬祖
    金門縣.金門
    雲林縣.台西
    雲林縣.崙背
    雲林縣.斗六
    雲林縣.麥寮
    高雄市.仁武
    高雄市.前金
    高雄市.前鎮
    高雄市.大寮
    高雄市.小港
    高雄市.左營
    高雄市.復興
    高雄市.林園
    高雄市.楠梓
    高雄市.橋頭
    高雄市.美濃
    高雄市.鳳山
);

my %trans = ();

for (@names) {
    my ($c, $n) = split /\./, $_;

    my $k0 = $c . $n;

    if (exists $name_trans{$k0}) {
        $trans{$k0} = $name_trans{$_};
    }
    else {
        my $found = 0;
        for (qw(縣 市 村 鎮 里 區)) {
            my $kn = $k0 . $_;
            # say "($_) $k0 => $name_trans{$kn}";
            if (exists $name_trans{$kn}) {
                $trans{$k0} = $name_trans{$kn};
                $found = 1;
            }
        }
        if (!$found) {
            say "NOT FOUND: $k0";

        }
    }
}

say JSON::PP->new->encode( \%trans );
