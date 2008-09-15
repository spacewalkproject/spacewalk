package Crypt::SSLeay::X509;

sub not_before {
    my $cert=shift;
    my $not_before_string=$cert->get_notBeforeString;
    &not_string2time($not_before_string);
}

sub not_after {
    my $cert=shift;
    my $not_after_string=$cert->get_notAfterString;
    &not_string2time($not_after_string);
}

sub not_string2time {
    my $string = shift;
    # $string has the form 021019235959Z
    my($year,$month,$day,$hour,$minute,$second,$GMT)=
      $string=~m/(\d\d)(\d\d)(\d\d)(\d\d)(\d\d)(\d\d)(Z)?/;
    $year += 2000;
    my $time="$year-$month-$day $hour:$minute:$second";
    $time .= " GMT" if $GMT;
    $time;
}

1;
