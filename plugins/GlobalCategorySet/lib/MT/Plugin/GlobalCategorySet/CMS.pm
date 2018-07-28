package MT::Plugin::GlobalCategorySet::CMS;
use strict;
use warnings;

use MT::Author;
use MT::Category;
use MT::CMS::Common;
use MT::Promise;
use MT::Util;

sub view_category {
    my $app = shift;

    return $app->errtrans('Invalid request.')
        unless MT::CMS::Common::is_enabled_mode( $app, 'edit', 'category' );

    my $id = $app->param('id');

    return $app->return_to_dashboard( redirect => 1 )
        unless $app->run_callbacks( 'cms_object_scope_filter.category', $app,
        $id );

    my $obj_promise = MT::Promise::delay( sub { MT::Category->load($id) } );

    return $app->permission_denied
        unless $app->user->is_superuser
        || $app->run_callbacks( 'cms_view_permission_filter.category',
        $app, $id, $obj_promise );

    my $obj = $obj_promise->force
        or return $app->errtrans( 'Load failed: [_1]',
        MT::Category->errstr || '(no reason given)' );

    my %param = ref $_[0] eq 'HASH' ? %{ $_[0] } : ();
    my @cols = @{ MT::Category->column_names };

    for my $col (@cols) {
        my $value = $app->param($col);
        $param{$col} = defined $value ? $value : $obj->$col;
    }

    my $created = MT::Author->load(
        {   id   => $obj->created_by,
            type => MT::Author::AUTHOR(),
        }
    );
    $param{created_by}
        = $created ? $created->name : $app->translate('(user deleted)');
    if ( $obj->modified_by ) {
        my $modified = MT::Author->load(
            {   id   => $obj->modified_by,
                type => MT::Author::AUTHOR(),
            }
        );
        $param{modified_by}
            = $modified ? $modified->name : $app->translate('(user deleted)');
    }

    if ( my $ts = $obj->modified_on ) {
        $param{modified_on_ts} = $ts;
        $param{modified_on_formatted}
            = MT::Util::format_ts( $app->LISTING_DATETIME_FORMAT,
            $ts, undef, $app->user ? $app->user->preferred_language : undef );
    }
    if ( my $ts = $obj->created_on ) {
        $param{created_on_ts} = $ts;
        $param{created_on_formatted}
            = MT::Util::format_ts( $app->LISTING_DATETIME_FORMAT,
            $ts, undef, $app->user ? $app->user->preferred_language : undef );
    }

    $param{new_object} = 0;

    {
        $param{tainted_input} = 0;
        local $app->{login_again};
        unless ( $app->validate_magic ) {
            $param{tainted_input} ||= ( $app->param($_) || '' ) !~ /^\d*$/
                for @cols;
        }
    }

    return $app->error( $app->callback_errstr )
        unless $app->run_callbacks( 'cms_edit.category', $app, $id, $obj,
        \%param );

    for my $p ( $app->multi_param ) {
        $param{$p} = $app->param($p) if $p =~ /^saved/;
    }

    $param{object_label}        = MT::Category->class_label;
    $param{object_label_plural} = MT::Category->class_label_plural;
    $param{object_type}  ||= 'category';
    $param{search_label} ||= MT::Category->class_label;
    $param{screen_id}    ||= 'edit-category';
    $param{screen_class} .= ' edit-category';

    $app->load_tmpl( 'edit_category.tmpl', \%param );
}

1;

