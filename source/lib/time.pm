#===================================================================
#        時刻操作に関わる関数
#-------------------------------------------------------------------
#            (C) 2013 @white_mns
#===================================================================

package TimeChecker;
use Cwd;
use Encode 'from_to';

# コンストラクタ
sub new {
  my $class = shift;
  
  bless {
    MessageList => [],
    TimeList    => [],
  }, $class;
}

# デストラクタ
sub delete{
    my $self = shift;
    @{ $self->{MessageList} } = undef;
    @{ $self->{TimeList} } = undef;
}

#-----------------------------------#
#    ファイル保存フォルダ用の日付取得
#-----------------------------------#
#    引数｜タグ名、cellpading数
#-----------------------------------#

sub GetFileDate {
    my $self    = shift;

    my $sec,my $min,my $hour,my $mday,my $mon,my $year,my $wday,my $yday,my $isdst;
    ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
    $year += 1900;
    $mon += 1;
    $mon  = sprintf("%02d", $mon);
    $mday = sprintf("%02d", $mday);
    $hour = sprintf("%02d", $hour);
    return "$year$mon$mday$hour";
}

#-----------------------------------#
#
#    現在時刻の出力
#
#-----------------------------------#
sub PresentTime{
    my $self = shift;
    
    #時間計測
    $times = time();
    ($sec,$min,$hour,$mday,$month,$year,$wday,$stime) = localtime($times);
    
    print("$hour:$min:$sec\n");
    return;
}

#-----------------------------------#
#
#    履歴記録
#
#-----------------------------------#
sub CheckTime{
    my $self    = shift;
    my $message = shift;
    #from_to($message, 'UTF8', 'cp932');
    
    #時間計測
    $times = time();
    ($sec,$min,$hour,$mday,$month,$year,$wday,$stime) = localtime($times);
    
    push( @{ $self->{MessageList} }, $message );
    push( @{ $self->{TimeList} }   , "$hour:$min:$sec" );
    
    print("$hour:$min:$sec\n");
    return;
}

#-----------------------------------#
#
#    履歴出力
#
#-----------------------------------#
sub OutputTime{
    my $self = shift;
    
    #二つの配列の長さが違う場合は何らかのエラー
    if( scalar(@{ $self->{MessageList} }) == scalar(@{ $self->{TimeList} })){
        
        
        for(my $i=0; $i < scalar(@{ $self->{TimeList} });$i++){
            print "\"" . ${$self->{MessageList}}[$i] . "\"　" . ${$self->{TimeList}}[$i] . "\n";
        }
    }else{
        print "errar:TimeChecker\n";
    }
    return;
}
1;
