use ExtUtils::MakeMaker;
WriteMakefile(
              NAME         => 'WWW::Google::News::TW',
              VERSION_FROM => 'lib/WWW/Google/News/TW.pm',
              PREREQ_PM    => {
                               Test::More => 0,
                              },
              AUTHOR       => 'Cheng-Lung Sung <clsung@dragon2.net>',
             );


