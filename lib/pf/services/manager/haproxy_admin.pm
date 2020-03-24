package pf::services::manager::haproxy_admin;
=head1 NAME

pf::services::manager::haproxy_admin add documentation

=cut

=head1 DESCRIPTION

pf::services::manager::haproxy_admin

=cut

use strict;
use warnings;
use Moo;
extends 'pf::services::manager::haproxy';

use pf::authentication;
use List::MoreUtils qw(uniq);
use pf::log;
use pf::util;
use pf::cluster;
use pf::config qw(
    %Config
    $OS
    $management_network
    @portal_ints
    @internal_nets
);
use pf::file_paths qw(
    $generated_conf_dir
    $conf_dir
    $var_dir
);

has '+name' => (default => sub { 'haproxy-admin' } );

has '+haproxy_config_template' => (default => sub { "$conf_dir/haproxy-admin.conf" });

my $host_id = $pf::config::cluster::host_id;

tie our %NetworkConfig, 'pfconfig::cached_hash', "resource::network_config($host_id)";

sub generateConfig {
    my ($self,$quick) = @_;
    my $logger = get_logger();
    my ($package, $filename, $line) = caller();

    my %tags;
    $tags{'template'} = $self->haproxy_config_template;
    $tags{'var_dir'} = $var_dir;
    $tags{'conf_dir'} = $var_dir.'/conf';
    $tags{'bind-process'} = '';
    my $bind_process = '';
    if ($OS eq 'debian') {
        $tags{'os_path'} = '/etc/haproxy/errors/';
    } else {
         $tags{'os_path'} = '/usr/share/haproxy/';
    }
    if ( $management_network && defined($management_network->{'Tip'}) && $management_network->{'Tip'} ne '') {
        my $mgmt_int = $management_network->tag('int');
        my $mgmt_cfg = $Config{"interface $mgmt_int"};
        $tags{'mgmt_active_ip'} = pf::cluster::management_cluster_ip() || $mgmt_cfg->{'vip'} || $mgmt_cfg->{'ip'};
        my $mgmt_cluster_ip = pf::cluster::cluster_ip($mgmt_int) || $mgmt_cfg->{'vip'} || $mgmt_cfg->{'ip'};
        my @mgmt_backend_ip = values %{pf::cluster::members_ips($mgmt_int)};
        push @mgmt_backend_ip, '127.0.0.1' if !@mgmt_backend_ip;

        $tags{'management_ip'}
            = defined( $management_network->tag('vip') )
            ? $management_network->tag('vip')
            : $management_network->tag('ip');


        my $portal_preview_ip = portal_preview_ip();
        my $mgmt_backend_ip_config;
        my $mgmt_backend_ip_api_config;
        my $mgmt_srv_netdata .= <<"EOT";

backend 127.0.0.1-netdata
        option httpclose
        option http_proxy
        option forwardfor
        acl paramsquery query -m found
        http-request lua.admin
        http-request set-uri http://127.0.0.1:19999%[var(req.path)]?%[query] if paramsquery
        http-request set-uri http://127.0.0.1:19999%[var(req.path)] unless paramsquery
EOT

        my $mgmt_api_backend;

        my $check = '';

        foreach my $mgmt_back_ip ( @mgmt_backend_ip ) {

            $mgmt_backend_ip_config .= <<"EOT";
        server $mgmt_back_ip $mgmt_back_ip:1443 check
EOT

            $mgmt_backend_ip_api_config .= <<"EOT";
        server $mgmt_back_ip $mgmt_back_ip:9999 weight 1 maxconn 100 check $check ssl verify none
EOT
            $check = 'backup';

            if ($mgmt_back_ip ne '127.0.0.1') {
                $mgmt_srv_netdata .= <<"EOT";

backend $mgmt_back_ip-netdata
        option httpclose
        option http_proxy
        option forwardfor
        acl paramsquery query -m found
        http-request lua.admin
        http-request set-uri http://$mgmt_back_ip:19999%[var(req.path)]?%[query] if paramsquery
        http-request set-uri http://$mgmt_back_ip:19999%[var(req.path)] unless paramsquery
EOT
            }
            $mgmt_api_backend .= <<"EOT";

backend $mgmt_back_ip-api
        balance source
        option httpclose
        option forwardfor
        server $mgmt_back_ip $mgmt_back_ip:9999 weight 1 maxconn 100 ssl verify none
EOT

        }
        $tags{'http_admin'} .= <<"EOT";

backend api
        balance source
        option httpclose
        option forwardfor
        errorfile 502 /usr/local/pf/html/pfappserver/root/static/502.json
$mgmt_backend_ip_api_config

frontend admin-https-$mgmt_cluster_ip
        bind $mgmt_cluster_ip:1443 ssl no-sslv3 crt /usr/local/pf/conf/ssl/server.pem
        capture request header Host len 40
        reqadd X-Forwarded-Proto:\\ https
        http-request lua.change_host
        acl host_exist var(req.host) -m found
        http-request set-header Host %[var(req.host)] if host_exist
        http-request lua.admin
        use_backend %[var(req.action)]
        default_backend $mgmt_cluster_ip-admin
        http-request redirect location /admin/alt if { lua.redirect 1 }

backend $mgmt_cluster_ip-admin
        balance source
        option httpclose
        option forwardfor
$mgmt_backend_ip_config

$mgmt_srv_netdata

$mgmt_api_backend

backend $mgmt_cluster_ip-portal
        option httpclose
        option http_proxy
        option forwardfor
        acl paramsquery query -m found
        http-request set-header Host $portal_preview_ip
        http-request lua.admin
        reqadd X-Forwarded-For-Packetfence:\\ 127.0.0.1
        http-request set-uri http://127.0.0.1:8890%[var(req.path)]?%[query] if paramsquery
        http-request set-uri http://127.0.0.1:8890%[var(req.path)] unless paramsquery

EOT
    } else {
        $tags{'management_ip'} = '127.0.0.1';

        $tags{'http_admin'} .= <<"EOT";
backend api
        balance source
        option httpclose
        option forwardfor
        errorfile 502 /usr/local/pf/html/pfappserver/root/static/502.json
        server 127.0.0.1 127.0.0.1:9999 weight 1 maxconn 100 check  ssl verify none

frontend admin-https-0.0.0.0
        bind 0.0.0.0:1443 ssl no-sslv3 crt /usr/local/pf/conf/ssl/server.pem
        capture request header Host len 40
        reqadd X-Forwarded-Proto:\\ https
        http-request lua.change_host
        acl host_exist var(req.host) -m found
        http-request set-header Host %[var(req.host)] if host_exist
        http-request lua.admin
        use_backend %[var(req.action)]
        http-request redirect location /admin/alt/index if { lua.redirect 1 }

EOT
    }
        parse_template( \%tags, $self->haproxy_config_template, "$generated_conf_dir/".$self->name.".conf" );

    my $config_file = "passthrough_admin.lua";
    my $vars;
    my $tt = Template->new(ABSOLUTE => 1);
    $tt->process("$conf_dir/$config_file.tt", $vars, "$generated_conf_dir/$config_file") or die $tt->error();

    return 1;
}


=head2 portal_preview_ip

The creates the portal preview ip addresss

=cut

sub portal_preview_ip {
    my ($self) = @_;
    if (!$cluster_enabled) {
        return "127.0.0.1";
    }
    my  @ints = uniq (@internal_nets, @portal_ints);
    return $ints[0]->{Tvip} ? $ints[0]->{Tvip} : $ints[0]->{Tip};
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>



=head1 COPYRIGHT

Copyright (C) 2005-2020 Inverse inc.

=head1 LICENSE

This program is free software; you can redistribute it and::or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301,
USA.

=cut

1;
