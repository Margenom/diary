#!/usr/bin/perl
use Mojolicious::Lite;

get '/' => { text => 'hello mojo'};
get 'temp' => { template => 'index'};

app->start;

__DATA__

@@ index.html.ep
<pre>
dsf
sdf
d
s
dsf
</pre>
