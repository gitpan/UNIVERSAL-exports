package UNIVERSAL::exports;
$UNIVERSAL::exports::VERSION = '0.01';


package UNIVERSAL;


=pod

=head1 NAME

UNIVERSAL::exports - Lightweight, universal exporting of variables

=head1 SYNOPSIS

  package Foo;
  use UNIVERSAL::exports;

  # Just like Exporter.
  @EXPORT       = qw($This &That);
  @EXPORT_OK    = qw(@Left %Right);


  # Meanwhile, in another piece of code!
  package Bar;
  use Foo;  # exports $This and &That.


=head1 DESCRIPTION

This is an alternative to Exporter intended to provide a universal,
lightweight subset of its functionality.  It supports C<import>,
C<@EXPORT> and C<@EXPORT_OK> and not a whole lot else.

Additionally, C<exports()> is provided to find out what symbols a
module exports.

UNIVERSAL::exports places its methods in the UNIVERSAL namespace, so
there is no need to subclass from it.


=head1 Methods

UNIVERSAL::exports has two public methods...

=over 4

=item B<import>

  Some::Module->import;
  Some::Module->import(@symbols);

Works just like C<Exporter::import()> excepting it only honors
@Some::Module::EXPORT and @Some::Module::EXPORT_OK.

The given @symbols are exported to the current package provided they
are in @Some::Module::EXPORT or @Some::Module::EXPORT_OK.  Otherwise
an exception is thrown (ie. the program dies).

If @symbols is not given, everything in @Some::Module::EXPORT is
exported.

=cut


sub import {
    my($exporter, @imports)  = @_;
    my($caller, $file, $line) = caller;

    unless( @imports ) {        # Default import.
        @imports = @{$exporter.'::EXPORT'};
    }
    else {
        # Because @EXPORT_OK = () would indicate that nothing is
        # to be exported, we cannot simply check the length of @EXPORT_OK.
        # We must to oddness to see if the variable exists at all as
        # well as avoid autovivification.
        # XXX idea stolen from base.pm, this might be all unnecessary
        my $eokglob;
        if( $eokglob = ${$exporter.'::'}{EXPORT_OK} and *$eokglob{ARRAY} ) {
            if( @{$exporter.'::EXPORT_OK'} ) {
                # This can also be cached.
                my %ok = map { $_ => 1} @{$exporter.'::EXPORT_OK'},
                                        @{$exporter.'::EXPORT'};

                my($denied) = grep {!$ok{$_}} @imports;
                _not_exported($denied, $exporter, $file, $line) if $denied;
            }
            else {      # We don't export anything.
                _not_exported($imports[0], $exporter, $file, $line);
            }
        }
    }

    _export($caller, $exporter, @imports);
}



sub _export {
    my($caller, $exporter, @imports) = @_;

    # Stole this from Exporter::Heavy.  I'm sure it can be written better
    # but I'm lazy at the moment.
    foreach $sym (@imports) {
        # shortcut for the common case of no type character
        (*{"${caller}::$sym"} = \&{"${exporter}::$sym"}, next)
            unless $sym =~ s/^(\W)//;
        my $type = $1;
        *{"${caller}::$sym"} =
            $type eq '&' ? \&{"${exporter}::$sym"} :
            $type eq '$' ? \${"${exporter}::$sym"} :
            $type eq '@' ? \@{"${exporter}::$sym"} :
            $type eq '%' ? \%{"${exporter}::$sym"} :
            $type eq '*' ?  *{"${exporter}::$sym"} :
            do { require Carp; Carp::croak("Can't export symbol: $type$sym") };
    }
}


#"#
sub _not_exported {
    my($thing, $exporter, $file, $line) = @_;
    die sprintf qq|"%s" is not exported by the %s module at %s line %d\n|,
        $thing, $exporter, $file, $line;
}


=pod

=item B<exports>

  @exported_symbols = Some::Module->exports;
  Some::Module->exports($symbol);

Reports what symbols are exported by Some::Module.  With no arguments,
it simply returns a list of all exportable symbols.  Otherwise, it
reports if it will export a given $symbol.

=cut


sub exports {
    my($exporter) = shift;

    my %exports = map { $_ => 1 } @{$exporter.'::EXPORT'}, 
                                  @{$exporter.'::EXPORT_OK'};

    if( @_ ) {
        return exists $exports{$_[0]};
    }
    else {
        return keys %exports;
    }
}


=pod

=head1 DIAGNOSTICS

=over 4

=item '"%s" is not exported by the %s module'

Attempted to import a symbol which is not in @EXPORT or @EXPORT_OK.

=item 'Can\'t export symbol: %s'

Attempted to import a symbol of an unknown type (ie. the leading $@% salad
wasn't recognized).

=back


=head1 AUTHORS

Michael G Schwern <schwern@pobox.com>

=head1 SEE ALSO

L<Exporter>, L<UNIVERSAL::require>, http://dev.perl.org/rfc/257.pod

=cut


007;
