package WWW::Google::News::TW;

use strict;
use warnings;

require Exporter;

our @ISA       = qw(Exporter);
our @EXPORT_OK = qw(get_news get_news_for_topic);
our $VERSION   = '0.01';

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

#  "&raquo;" >>
#  my $re1 =  '<a name=(.*?)(?:<a name=|<br clear=all)';
  my $re1 =  '<td bgcolor=#efefef class=ks width=1% nowrap>(.*?)</td>';
  my $re2 =  '<a href="([^"]*)" id=r-\d-\d target=_blank><b>([^<]*)</b></a><br>';

  my @sections = split /($re1)/m,$response->content;
  my $current_section = '';
#  print STDERR "total num is ".$#sections."\n";
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
          push(@{$results->{$current_section}},$story_h);
        }
      }
    }
  }
  # print STDERR Dumper($results);
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
                          'url' => 'http://udn.com/NEWS/LIFE/LIFS2/2233728.shtml',
                          'headline' => '中華電配線費四樓以下建物免收'
                        },
                      ],
          '焦點' => [
                        {
                          'url' => 'http://www.ettoday.com/2004/09/09/153-1683695.htm',
                          'headline' => '來去嘉義／阿里山鐵路接駁通車走走停停別有風味'
                        },
                      ],
   }

=head1 METHODS

=over 4

=item get_news()

Scrapes L<http://news.google.com.tw/news?ned=ttw> and returns a reference 
to a hash keyed on News Section, which points to an array of hashes keyed on URL and Headline.

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

=head1 SEE ALSO

L<WWW::Google::News>, L<http://news.google.com.tw/>

=cut
