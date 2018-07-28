package MT::Plugin::GlobalCategorySet::ContentFieldType;
use strict;
use warnings;

use MT::ContentFieldType::Categories;

sub field_html_params {
    my ( $app, $field_data ) = @_;
    my $category_set_id = $field_data->{options}{category_set} || 0;
    my $category_set = $app->model('category_set')->load($category_set_id);
    local $app->{_blog} = $app->model('blog')->new( id => 0 )
        unless $category_set->blog_id;
    MT::ContentFieldType::Categories::field_html_params(@_);
}

sub field_type_validation_handler {
    my ($app) = @_;
    my $blog_id
        = ( $app->blog && $app->blog->id ) ? [ 0, $app->blog->id ] : 0;
    local $app->{_blog} = $app->model('blog')->new( id => $blog_id );
    MT::ContentFieldType::Categories::field_type_validation_handler(@_);
}

sub options_html_params {
    my ( $app, $param ) = @_;
    my $blog_id
        = ( $app->blog && $app->blog->id ) ? [ 0, $app->blog->id ] : 0;
    local $app->{_blog} = $app->model('blog')->new( id => $blog_id );
    MT::ContentFieldType::Categories::options_html_params(@_);
}

sub options_validation_handler {
    my ( $app, $type, $label, $field_label, $options ) = @_;
    my $blog_id
        = ( $app->blog && $app->blog->id ) ? [ 0, $app->blog->id ] : 0;
    local $app->{_blog} = $app->model('blog')->new( id => $blog_id );
    MT::ContentFieldType::Categories::options_validation_handler(@_);
}

1;

