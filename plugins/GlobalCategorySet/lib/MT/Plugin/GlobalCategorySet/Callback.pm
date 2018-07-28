package MT::Plugin::GlobalCategorySet::Callback;
use strict;
use warnings;

use MT;
use MT::CMS::Category;

sub init_app {
    _override_cms_category_bulk_update();
    _override_cms_category_js_add_category();
    _override_list_prop_category_entry_count();
    _override_cb_list_tmpl_param_category();
}

sub cms_pre_load_filtered_list {
    my ( $cb, $app, $filter, $options, $cols ) = @_;
    return if $app->blog;
    $options->{terms}{blog_id} = 0;
}

sub _override_cms_category_bulk_update {
    my $bulk_update = \&MT::CMS::Category::bulk_update;
    no warnings 'redefine';
    *MT::CMS::Category::bulk_update = sub {
        my $app = shift;
        local $app->{_blog} = MT->model('blog')->new( class => 'system' )
            unless $app->blog;
        $bulk_update->( $app, @_ );
    };
}

sub _override_cms_category_js_add_category {
    my $js_add_category = \&MT::CMS::Category::js_add_category;
    no warnings 'redefine';
    *MT::CMS::Category::js_add_category = sub {
        my $app = shift;
        $app->blog;
        my $orig_blog_id = $app->blog->id;

        my $category_set_id = $app->param('category_set_id') || 0;
        my $category_set
            = $app->model('category_set')->load($category_set_id);
        $app->param( 'blog_id', $category_set->blog_id ) if $category_set;
        my $ret = $js_add_category->( $app, @_ );

        $app->param( 'blog_id', $orig_blog_id ) if $category_set;
        $ret;
    };
}

sub _override_list_prop_category_entry_count {
    my $reg = MT->registry( 'list_properties', 'category' );
    my $bulk_html = $reg->{entry_count}{bulk_html};
    $reg->{entry_count}{bulk_html} = sub {
        my $app = $_[2];
        return '' unless $app->blog;
        $bulk_html->(@_);
    };
}

sub _override_cb_list_tmpl_param_category {
    my $template_param_list = \&MT::CMS::Category::template_param_list;
    no warnings 'redefine';
    *MT::CMS::Category::template_param_list = sub {
        my ( $_cb, $app ) = @_;
        local $app->{_blog} = MT->model('blog')->new( id => 0 )
            unless $app->blog;
        $template_param_list->(@_);
    };
}

1;

