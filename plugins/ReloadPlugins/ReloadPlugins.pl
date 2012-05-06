package MT::Plugin::ReloadPlugins;
use strict;
use warnings;
use base 'MT::Plugin';

our $VERSION = '0.01';
our $NAME    = ( split /::/, __PACKAGE__ )[-1];

my $plugin = __PACKAGE__->new({
    name => $NAME,
    id => lc $NAME,
    key => lc $NAME,
    l10n_class => $NAME . '::L10N',
    version => $VERSION,
    author_name => 'masiuchi',
    author_link => 'https://github.com/masiuchi',
    plugin_link => 'https://github.com/masiuchi/mt-plugin-restart-reload-plugins',
    description => 'Add the reload plugins link in plugin settings view for FastCGI.',
});
MT->add_plugin( $plugin );

sub init_registry {
    my ( $p ) = @_;
    my $pkg = '$' . $NAME . '::' . $NAME;
    $p->registry({
        applications => {
            cms => {
                methods => {
                    reload_plugins => $pkg . '::CMS::reload_plugins',
                },
            },
        },
        callbacks => {
            'MT::App::CMS::template_source.cfg_plugin' => $pkg . '::CMS::tmpl_src_cfg_plugin',
        },
    });
}

1;
__END__
