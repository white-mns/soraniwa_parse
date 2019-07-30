#===================================================================
#        戦闘結果解析パッケージ
#-------------------------------------------------------------------
#            (C) 2019 @white_mns
#===================================================================


# パッケージの使用宣言    ---------------#
use strict;
use warnings;

use ConstData;
use HTML::TreeBuilder;
use source::lib::GetNode;

require "./source/lib/IO.pm";
require "./source/lib/time.pm";

require "./source/battle/LatestRNo.pm";
require "./source/battle/Page.pm";
#require "./source/battle/Party.pm";
#require "./source/battle/Enemy.pm";

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
                                         { $self->{DataHandlers}{LatestRNo}  = LatestRNo->new();}
    if (ConstData::EXE_BATTLE_PAGE)      { $self->{DataHandlers}{Page}       = Page->new();}
    #if (ConstData::EXE_BATTLE_PARTY)     { $self->{DataHandlers}{Party} = Party->new();}
    #if (ConstData::EXE_BATTLE_ENEMY)     { $self->{DataHandlers}{Enemy} = Enemy->new();}

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

    print "read character files...\n";

    my $start = 1;
    my $end   = 0;
    my $directory = './data/orig/result/';

    if (defined($self->{StartNo}) && $self->{StartNo} =~ /^[0-9]+$/) {
        #指定範囲解析
        $start = $self->{StartNo}

    } else {
        $start = $self->{DataHandlers}{LatestRNo}->GetLatestRNo($end);
    }

    if (defined($self->{EndNo}) && $self->{EndNo} =~ /^[0-9]+$/) {
        #指定範囲解析
        $end = $self->{EndNo}

    } else {
        $end   = GetMaxFileNo($directory,"");
        $self->{DataHandlers}{LatestRNo}->SetLatestRNo($end);
    }

    print "$start to $end\n";

    for (my $r_no=$start; $r_no<=$end; $r_no++) {
        if ($r_no % 10 == 0) {print $r_no . "\n"};

        $self->ParsePage($directory.$r_no.".html.gz",$r_no);
    }
    
    return ;
}
#-----------------------------------#
#       ファイルを解析
#-----------------------------------#
#    引数｜ファイル名
#    　　　ENo
##-----------------------------------#
sub ParsePage{
    my $self       = shift;
    my $file_name  = shift;
    my $battle_no  = shift;

    #結果の読み込み
    my $content = "";
    $content = &IO::FileRead($file_name);

    if (!$content) { return;}

    #スクレイピング準備
    my $tree = HTML::TreeBuilder->new;
    $tree->parse($content);

    my $title_b_nodes = &GetNode::GetNode_Tag_Attr("b", "class", "T6", \$tree);
    my $turn_table_nodes = &GetNode::GetNode_Tag_Attr("table", "width", "700", \$tree);
    my $t6i_td_nodes = &GetNode::GetNode_Tag_Attr("td", "class", "T6i", \$tree);

    # データリスト取得
    #if (exists($self->{DataHandlers}{Page}))  {$self->{DataHandlers}{Page}->GetData ($battle_no, $turn_table_nodes, $$title_b_nodes[0], $t6i_td_nodes)};
    #if (exists($self->{DataHandlers}{Party})) {$self->{DataHandlers}{Party}->GetData($battle_no, $turn_table_nodes)};
    #if (exists($self->{DataHandlers}{Enemy})) {$self->{DataHandlers}{Enemy}->GetData($battle_no, $turn_table_nodes)};

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
