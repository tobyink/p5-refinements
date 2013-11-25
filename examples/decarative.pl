BEGIN {
	package LwpDebugging;
	use Refinements::Declare;
	
	refine LWP::UserAgent::request ($req, ...)
	{
		warn sprintf 'REQUEST: %s %s', $req->method, $req->uri;
		return $self->$next(@_);
	}
};

{
	package MyApp;
	
	use LWP::UserAgent;
	
	my $ua  = LWP::UserAgent->new;
	my $req = HTTP::Request->new(GET => 'http://www.example.com/');
	
	{
		use LwpDebugging;
		
		my $res = $ua->request($req);   # issues debugging warning
		
		# $ua->get internally calls $ua->request
		my $res2 = $ua->get('http://www.example.org/');  # no warning
	}
	
	my $res = $ua->request($req);  # no warning
}
