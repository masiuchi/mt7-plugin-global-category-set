use strict;
use warnings;

use Test::More;

use FindBin;
use lib "$FindBin::Bin/../../../lib", "$FindBin::Bin/../../../extlib",
    "$FindBin::Bin/../lib";

use_ok('MT::Plugin::GlobalCategorySet::Callback');
use_ok('MT::Plugin::GlobalCategorySet::CMS');
use_ok('MT::Plugin::GlobalCategorySet::ContentFieldType');

done_testing;

