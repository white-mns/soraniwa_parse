#===================================================================
#        戦闘結果解析パッケージ
#-------------------------------------------------------------------
#            (C) 2019 @white_mns
#===================================================================


# パッケージの使用宣言    ---------------#
use strict;
use warnings;

use HTML::TreeBuilder;
use source::lib::GetNode;

require "./source/lib/IO.pm";
require "./source/lib/time.pm";

require "./source/battle/LatestApNo.pm";
require "./source/battle/Ap.pm";
require "./source/battle/Party.pm";
require "./source/battle/Enemy.pm";
require "./source/battle/Drop.pm";

use ConstData;        #定数呼び出し

#------------------------------------------------------------------#
#    パッケージの定義
#------------------------------------------------------------------#
package Battle;

#-----------------------------------#
#    コンストラクタ
#-----------------------------------#
sub new {
  my $class = shift;

  bless {
    Datas         => {},
    DataHandlers  => {},
    Methods       => {},
  }, $class;
}

#-----------------------------------#
#    初期化
#-----------------------------------#
sub Init() {
    my $self = shift;
    ($self->{StartNo}, $self->{EndNo}, $self->{CommonDatas}) = @_;

    #インスタンス作成
                                       { $self->{DataHandlers}{LatestApNo} = LatestApNo->new();}
    if (ConstData::EXE_BATTLE_AP)      { $self->{DataHandlers}{Ap}         = Ap->new();}
    if (ConstData::EXE_BATTLE_PARTY)   { $self->{DataHandlers}{Party}      = Party->new();}
    if (ConstData::EXE_BATTLE_ENEMY)   { $self->{DataHandlers}{Enemy}      = Enemy->new();}
    if (ConstData::EXE_BATTLE_DROP)    { $self->{DataHandlers}{Drop}       = Drop->new();}

    #初期化処理
    foreach my $object( values %{ $self->{DataHandlers} } ) {
        $object->Init($self->{CommonDatas});
    }
    
    return;
}

#-----------------------------------#
#    圧縮結果から戦闘結果ファイルを抽出
#-----------------------------------#
#    
#-----------------------------------#
sub Execute{
    my $self        = shift;

    print "read battle files...\n";

    my $start = 1;
    my $end   = 0;
    my $directory = './data/orig/result/';

    if (defined($self->{StartNo}) && $self->{StartNo} =~ /^[0-9]+$/) {
        #指定範囲解析
        $start = $self->{StartNo}

    } else {
        $start = $self->{DataHandlers}{LatestApNo}->GetLatestApNo($end);
    }

    if (defined($self->{EndNo}) && $self->{EndNo} =~ /^[0-9]+$/) {
        #指定範囲解析
        $end = $self->{EndNo}

    } else {
        $end   = GetMaxFileNo($directory,"");
        $self->{DataHandlers}{LatestApNo}->SetLatestApNo($end);
    }

    print "$start to $end\n";

    for (my $ap_no=$start; $ap_no<=$end; $ap_no++) {
        if ($ap_no % 10 == 0) {print $ap_no . "\n"};

        $self->ParseAp($directory.$ap_no.".html.gz",$ap_no);
    }
    
    return ;
}
#-----------------------------------#
#       ファイルを解析
#-----------------------------------#
#    引数｜ファイル名
#    　　　ENo
##-----------------------------------#
sub ParseAp{
    my $self       = shift;
    my $file_name  = shift;
    my $ap_no  = shift;

    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime((stat $file_name)[9]);
    my $last_modified = ($year+1900) . "-" . sprintf("%02d", $mon + 1) . "-" . sprintf("%02d",$mday);

    #結果の読み込み
    my $content = "";
    $content = &IO::GzipRead($file_name);

    if (!$content) { return;}

    #スクレイピング準備
    my $tree = HTML::TreeBuilder->new;
    $tree->parse($content);

    my $div_frameareab_nodes = &GetNode::GetNode_Tag_Attr("div", "class", "frameareab", \$tree);
    my $h2_subtitle_nodes    = &GetNode::GetNode_Tag_Attr("h2",  "class", "subtitle",   \$tree);
    my $h3_nodes = &GetNode::GetNode_Tag("h3", \$tree);
    my $h4_nodes = &GetNode::GetNode_Tag("h4", \$tree);
    my $b_csred_nodes = &GetNode::GetNode_Tag_Attr("b", "class", "csred", \$tree);

    # データリスト取得
    if (exists($self->{DataHandlers}{Ap}))    {$self->{DataHandlers}{Ap}->GetData   ($ap_no, $last_modified, $$h2_subtitle_nodes[0], $div_frameareab_nodes, $h3_nodes, $$b_csred_nodes[0])};
    if (exists($self->{DataHandlers}{Party})) {$self->{DataHandlers}{Party}->GetData($ap_no, $div_frameareab_nodes)};
    if (exists($self->{DataHandlers}{Enemy})) {$self->{DataHandlers}{Enemy}->GetData($ap_no, $div_frameareab_nodes)};
    if (exists($self->{DataHandlers}{Drop}))  {$self->{DataHandlers}{Drop}->GetData ($ap_no, $h4_nodes)};

    $tree = $tree->delete;
}

#-----------------------------------#
#       該当ファイル最大番号を取得
#-----------------------------------#
#    引数｜ディレクトリ名
#    　　　ファイル接頭辞
##-----------------------------------#
sub GetMaxFileNo{
    my $directory   = shift;
    my $prefix    = shift;

    #ファイル名リストを取得
    my @fileList = grep { -f } glob("$directory/$prefix*.html.gz");

    my $max= 0;
    foreach (@fileList) {
        $_ =~ /$prefix(\d+).html.gz/;
        if ($max < $1) {$max = $1;}
    }
    return $max;
}

#-----------------------------------#
#       該当ファイル最小番号を取得
#-----------------------------------#
#    引数｜ディレクトリ名
#    　　　ファイル接頭辞
##-----------------------------------#
sub GetMinFileNo{
    my $directory   = shift;
    my $prefix    = shift;

    #ファイル名リストを取得
    my @fileList = grep { -f } glob("$directory/$prefix*.html.gz");

    my $min= 9999999;
    foreach (@fileList) {
        $_ =~ /$prefix(\d+).html.gz/;
        if ($min > $1) {$min = $1;}
    }
    return $min;
}


#-----------------------------------#
#    出力
#-----------------------------------#
#    引数｜ファイルアドレス
#-----------------------------------#
sub Output(){
    my $self = shift;
    foreach my $object( values %{ $self->{Datas} } ) {
        $object->Output();
    }
    foreach my $object( values %{ $self->{DataHandlers} } ) {
        $object->Output();
    }
    return;
}

1;
