package WWW::Google::News::TW;

use strict;
use warnings;

require Exporter;

our @ISA       = qw(Exporter);
our @EXPORT_OK = qw(get_news get_news_for_topic);
our $VERSION   = '0.02';

use Carp;
use LWP;
use URI::Escape;

sub get_news {
    # Web version: http://news.google.com.tw/news?ned=tw
    # plain text version : http://news.google.com.tw/news?ned=ttw
  my $url = 'http://news.google.com.tw/news?ned=ttw';
  my $ua = LWP::UserAgent->new;
     $ua->agent('Mozilla/5.0');
  my $response = $ua->get($url);
  my $results = {};
  return unless $response->is_success;

  my $re1 =  '<td bgcolor=#efefef class=ks width=1% nowrap>(.*?)</td>';
  my $re2 =  '<a href="([^"]*)" id=r-\d-\d target=_blank><b>([^<]*)</b></a><br>'.
	    '<font size=-1><font color=#6f6f6f><b>([^<]*)</font>'.
	    '\s?<nobr>([^<]*)</nobr></b></font><br>'.
	    '<font size=-1>([^<]*)<b>...</b>';

  my @sections = split /($re1)/m,$response->content;
  my $current_section = '';
  foreach my $section (@sections) {
    if ($section =~ m/$re1/m) {
      $current_section = $1;
      $current_section =~ s/&nbsp;//g; # or put this &nbsp;(.*?)(?:&nbsp;)? in re1
      #print STDERR $1,"\n";
    } else {
      my @stories = split /($re2)/mi,$section;
      foreach my $story (@stories) {
        if ($story =~ m/$re2/mi) {
          if (!(exists($results->{$current_section}))) {
            $results->{$current_section} = [];
          }
          my $story_h = {};
          $story_h->{url} = $1;
          $story_h->{headline} = $2;
	  $story_h->{source} = $3;
	  $story_h->{source} =~ s/&nbsp;-//g;
	  $story_h->{update_time} = $4;
	  $story_h->{summary} = $5;
          push(@{$results->{$current_section}},$story_h);
        }
      }
    }
  }
  return $results;
}

1;

__END__

=head1 NAME

WWW::Google::News::TW - Access to Google's Taiwan News Service (Not Usenet)

=head1 SYNOPSIS

  use WWW:Google::News::TW qw(get_news);
  my $results = get_news();
  
=head1 DESCRIPTION

This module provides a couple of methods to scrape results from Google Taiwan News, returning 
a data structure similar to the following (which happens to be suitable to feeding into XML::RSS).

  {
          '社會' => [
                        {
                          'update_time' => '11小時前',
                          'source' => '聯合新聞網-',
                          'summary' => '不少民眾向公平會檢舉，質疑中華電信每月帳單收取五元「屋內配線月租費」的合理性。公平會昨天決議，要求中華電信要讓樓高四樓以下的用戶，免收五元月租費，並把訊息揭露在電信帳單 ',
                          'url' => 'http://udn.com/NEWS/LIFE/LIFS2/2233728.shtml',
                          'headline' => '中華電配線費四樓以下建物免收'
                        },
                      ],
          '娛樂' => [
                        {
                          'update_time' => '2小時前',
                          'source' => '瀟湘晨報-',
                          'summary' => '本報綜合消息台灣金馬影展執委會昨日公佈本年度活動海報，兩款三幅都以彩虹為視覺主題，象徵電影的光影與夢想，強調創作者電影夢的實現，也是觀眾體驗電影夢的過程 ',
                          'url' => 'http://220.168.28.52:828/xxcb.rednet.com.cn/Articles/04/09/10/544900.HTM',
                          'headline' => '2004金馬影展海報出爐'
                        },
   }

=head1 METHODS

=over 4

=item get_news()

Scrapes L<http://news.google.com/news/gnmainlite.html> and returns a reference 
to a hash keyed on News Section, which points to an array of hashes keyed on URL and Headline.

=head1 SEE ALSO

L<WWW::Google::News>, L<http://news.google.com.tw/>

=head1 TODO

* Add topic search

=head1 AUTHORS

Cheng-Lung Sung E<lt>clsung@dragon2.netE<gt>

=head1 KUDOS

Greg McCarroll <greg@mccarroll.demon.co.uk>, Bowen Dwelle <bowen@dwelle.org>
for the basis of this module

=head1 COPYRIGHT

Copyright 2004 by Cheng-Lung Sung E<lt>clsung@dragon2.netE<gt>.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

See L<http://www.perl.com/perl/misc/Artistic.html>

=cut
