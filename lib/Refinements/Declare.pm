use 5.014;
use strict;
use warnings;

{
	package Refinements::Declare;
	
	use Kavorka qw(around);
	use Refinements ();
	
	our $AUTHORITY   = 'cpan:TOBYINK';
	our $VERSION     = '0.001';
	our @ISA         = qw( Kavorka );
	our @EXPORT      = qw( fun refine );
	our @EXPORT_OK   = (@Kavorka::EXPORT_OK, qw( refine ));
	our %EXPORT_TAGS = %Kavorka::EXPORT_TAGS;
	
	around guess_implementation ($next, $class: Str $kw)
	{
		return 'Refinements::Declare::Sub'
			if $kw eq 'refine';
		
		$class->$next(@_);
	}
	
	around _exporter_validate_opts ($next, $class: ...)
	{
		$class->Refinements::_exporter_validate_opts(@_);
		$class->$next(@_);
	}
}

{
	package Refinements::Declare::Sub;
	
	use Moo;
	use Kavorka qw(method);
	
	our $AUTHORITY = 'cpan:TOBYINK';
	our $VERSION   = '0.001';
	
	method allow_anonymous { 0 }
	method allow_lexical   { 0 }
	
	method default_invocant ()
	{
		return (
			'Kavorka::Parameter'->new(
				name      => '$next',
				traits    => { invocant => 1 },
			),
			'Kavorka::Parameter'->new(
				name      => '$self',
				traits    => { invocant => 1 },
			),
		);
	}
	
	method install_sub ()
	{
		$self->package->add_refinement(
			$self->declared_name,
			$self->body,
		);
	}
	
	with qw( Kavorka::Sub );
}

1;

__END__

=pod

=encoding utf-8

=head1 NAME

Refinements::Declare - experimental declarative syntax for refinements

=head1 SYNOPSIS

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

=head1 DESCRIPTION

This is an experimental declarative interface for L<Refinements>
using L<Kavorka>.

It provides a keyword C<refine> which can be used to declare a
refinement. Refinements default to taking two invocants (C<< $next >>
and C<< $self >>).

It also provides the standard Kavorka C<fun> keyword for declaring
helper functions.

=head1 BUGS

Please report any bugs to
L<http://rt.cpan.org/Dist/Display.html?Queue=Refinements>.

=head1 SEE ALSO

L<Refinement>, L<Kavorka>.

=head1 AUTHOR

Toby Inkster E<lt>tobyink@cpan.orgE<gt>.

=head1 COPYRIGHT AND LICENCE

This software is copyright (c) 2013 by Toby Inkster.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=head1 DISCLAIMER OF WARRANTIES

THIS PACKAGE IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS OR IMPLIED
WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF
MERCHANTIBILITY AND FITNESS FOR A PARTICULAR PURPOSE.

