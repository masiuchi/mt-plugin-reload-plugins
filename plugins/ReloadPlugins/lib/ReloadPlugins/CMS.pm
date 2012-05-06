package ReloadPlugins::CMS;
use strict;
use warnings;

my $Name   = ( split /::/, __PACKAGE__ )[0];
my $Plugin = MT->component( $Name );

sub reload_plugins {
    my ( $app ) = @_;
                
    if ( _check_perm( $app ) ) {
        require MT::Touch;
        MT::Touch->touch( 0, 'config' );
        
        return $app->redirect(
            $app->uri(
                mode => 'cfg_plugins',
                args => {
                    blog_id => $app->param( 'blog_id' ) || 0,
                },
            ),
            UseMeta => 1,
        );
    } else {
        return $app->permission_denied();
    }
}

sub _check_perm {
    my ( $app ) = @_;

    my $flag;

    my $blog_id = $app->param( 'blog_id' );
    if ( $blog_id ) {
        my $blog = $app->model( 'blog' )->load( $blog_id );
        if ( $blog ) {
            $flag = $blog->is_blog
                ? $app->can_do( 'administer_blog' )
                : $app->can_do( 'administer_website' );
            $flag = $flag ? 1 : 0;
        } else {
            $flag = 0;
        }
    } else {
        $flag = $app->can_do( 'manage_plugins' ) ? 1 : 0;
    }

    return $flag;
}

sub tmpl_src_cfg_plugin {
    my ( $cb, $app, $tmpl_ref ) = @_;

    my $reload_plugins = $Plugin->translate( 'Reload Plugins' );

    if ( $ENV{FAST_CGI} ) {
        my $old = quotemeta( <<'HTMLHEREDOC' );
<mt:setvarblock name="content_header">
<ul class="action-link-list">
  <li><a href="<__trans phrase="_PLUGIN_DIRECTORY_URL">" class="icon-left icon-related" target="_blank"><__trans phrase="Find Plugins"></a></li>
HTMLHEREDOC
    
        my $new = <<"HTMLHEREDOC";
  <li><a href="<mt:var name="script_url">?__mode=reload_plugins&blog_id=<mt:var name="blog_id">" class="icon-left icon-related">$reload_plugins</a></li>
HTMLHEREDOC
        
        $$tmpl_ref =~ s!($old)!$1$new!;
    }           
}     

1;
__END__
