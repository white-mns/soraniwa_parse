#===================================================================
#        ステータス取得パッケージ
#-------------------------------------------------------------------
#            (C) 2019 @white_mns
#===================================================================


# パッケージの使用宣言    ---------------#   
use strict;
use warnings;
require "./source/lib/Store_Data.pm";
require "./source/lib/Store_HashData.pm";
use ConstData;        #定数呼び出し
use source::lib::GetNode;


#------------------------------------------------------------------#
#    パッケージの定義
#------------------------------------------------------------------#     
package Status;

#-----------------------------------#
#    コンストラクタ
#-----------------------------------#
sub new {
  my $class = shift;
  
  bless {
        Datas => {},
  }, $class;
}

#-----------------------------------#
#    初期化
#-----------------------------------#
sub Init{
    my $self = shift;
    ($self->{Date}, $self->{CommonDatas}) = @_;
    
    #初期化
    $self->{Datas}{Data}  = StoreData->new();
    my $header_list = "";
   
    $header_list = [
                "e_no",
                "str",
                "mag",
                "agi",
                "vit",
                "dex",
                "mnt",
                "battle_type_id",
                "battle_type_color_id",
                "fan_of_flower_id",
                "line_id",
                "created_at",
    ];

    $self->{Datas}{Data}->Init($header_list);
    
    #出力ファイル設定
    $self->{Datas}{Data}->SetOutputName( "./output/chara/status_" . $self->{Date} . ".csv" );
    return;
}

#-----------------------------------#
#    データ取得
#------------------------------------
#    引数｜e_no,サブキャラ番号,ステータステーブルノード
#-----------------------------------#
sub GetData{
    my $self    = shift;
    my $e_no    = shift;
    my $div_cdatal_node = shift;
    
    $self->{ENo} = $e_no;

    $self->GetStatusData($div_cdatal_node);
    
    return;
}
#-----------------------------------#
#    ステータスデータ取得
#------------------------------------
#    引数｜ステータステーブルノード
#-----------------------------------#
sub GetStatusData{
    my $self  = shift;
    my $div_cdatal_node = shift;
    my ($str, $mag, $agi, $vit, $dex, $mnt, $battle_type_id, $battle_type_color_id, $fan_of_flower_id, $line_id) = (0, 0, 0, 0, 0, 0, 0, 0, 0, 0);

    my $span_markd_nodes = &GetNode::GetNode_Tag_Attr_RegExp("span", "class", "markd",  \$div_cdatal_node);
    
    foreach my $node (@$span_markd_nodes) {
        my $item =  $node->as_text;
        if ($item eq "STR") {
            $str = $node->right->as_text;

        } elsif ($item eq "MAG") {
            $mag = $node->right->as_text;

        } elsif ($item eq "AGI") {
            $agi = $node->right->as_text;

        } elsif ($item eq "VIT") {
            $vit = $node->right->as_text;

        } elsif ($item eq "DEX") {
            $dex = $node->right->as_text;

        } elsif ($item eq "MNT") {
            $mnt = $node->right->as_text;

        } elsif ($item eq "タイプ") {
            my $battle_type_name = $node->right->as_text;
            $battle_type_name =~ s/【✿//g;
            $battle_type_name =~ s/】//g;
            $battle_type_id = $self->{CommonDatas}{ProperName}->GetOrAddId($battle_type_name);
            
            my @child_nodes = $node->right->content_list;
            if (scalar(@child_nodes)) {
                $battle_type_color_id = $child_nodes[0]->attr("class");
                $battle_type_color_id =~ s/type//;
            }

        } elsif ($item eq "推し花") {
            $fan_of_flower_id = $self->{CommonDatas}{ProperName}->GetOrAddId($node->right->as_text);

        } elsif ($item eq "隊列") {
            $line_id = ($node->right->as_text eq "前列") ? 0 : 1;
        }
    }

    $self->{Datas}{Data}->AddData(join(ConstData::SPLIT, ($self->{ENo}, $str, $mag, $agi, $vit, $dex, $mnt, $battle_type_id, $battle_type_color_id, $fan_of_flower_id, $line_id, $self->{Date}) ));

    return;
}

#-----------------------------------#
#    出力
#------------------------------------
#    引数｜
#-----------------------------------#
sub Output{
    my $self = shift;
    
    foreach my $object( values %{ $self->{Datas} } ) {
        $object->Output();
    }
    return;
}
1;
