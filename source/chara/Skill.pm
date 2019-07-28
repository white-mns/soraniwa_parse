#===================================================================
#        設定スキル取得パッケージ
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
package Skill;

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
                "set_no",
                "skill_type_id",
                "type_id",
                "nature_id",
                "skill_id",
                "name",
                "timing_id",
                "created_at",
    ];

    $self->{Datas}{Data}->Init($header_list);
    
    #出力ファイル設定
    $self->{Datas}{Data}->SetOutputName( "./output/chara/skill_" . $self->{Date} . ".csv" );
    return;
}

#-----------------------------------#
#    データ取得
#------------------------------------
#    引数｜e_no,サブキャラ番号,スキルテーブルノード
#-----------------------------------#
sub GetData{
    my $self    = shift;
    my $e_no    = shift;
    my $div_cdatal_node = shift;
    
    $self->{ENo} = $e_no;

    $self->GetSkillData($div_cdatal_node);
    
    return;
}
#-----------------------------------#
#    スキルデータ取得
#------------------------------------
#    引数｜スキルテーブルノード
#-----------------------------------#
sub GetSkillData{
    my $self  = shift;
    my $div_cdatal_node = shift;

    my $span_marks_marki0_nodes = &GetNode::GetNode_Tag_Attr("span", "class", "marks marki0",  \$div_cdatal_node);
    
    foreach my $node (@$span_marks_marki0_nodes) {
        my ($set_no, $skill_type_id, $type_id, $nature_id, $skill_id, $name, $timing_id) = (0, 0, 0, 0, 0, "", 0);

        my $item =  $node->as_text;
        $set_no = $node->as_text;

        my $skill_node = $node->right;
        my @skill_child_nodes = $skill_node->content_list;

        if (scalar(@skill_child_nodes)<2) {next;}

        $type_id = $skill_child_nodes[0]->attr("class");
        $type_id =~ s/type//;

        my $text_node = $skill_node->right;
        my $b_nodes = &GetNode::GetNode_Tag("b",  \$text_node);
        if (scalar(@$b_nodes)) {
            my $timing = $$b_nodes[0]->as_text;
            $timing =~ s/: //g;
            $timing_id = $self->{CommonDatas}{ProperName}->GetOrAddId($timing);
        }

        my $text_span_nodes = &GetNode::GetNode_Tag("span",  \$text_node);
        my $text = "";
        if (scalar(@$b_nodes)) {
            $text = $$text_span_nodes[0]->as_text;
        }

        $skill_id = $skill_child_nodes[1];
        $skill_id = $self->{CommonDatas}{SkillData}->GetOrAddId(1, [$skill_child_nodes[1], " ", $text]);

        $self->{Datas}{Data}->AddData(join(ConstData::SPLIT, ($self->{ENo}, $set_no, $skill_type_id, $type_id, $nature_id, $skill_id, $name, $timing_id, $self->{Date}) ));
    }

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
