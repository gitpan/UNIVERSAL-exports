package UNIVERSAL::require;
$UNIVERSAL::require::VERSION = '0.03';

# We do this because UNIVERSAL.pm uses CORE::require().  We're going
# to put our own require() into UNIVERSAL and that makes an ambiguity.
# So we load it up beforehand to avoid that.
BEGIN { require UNIVERSAL }

package UNIVERSAL;

use strict;

=pod

=head1 NAME

  UNIVERSAL::require - require() modules from a variable

=head1 SYNOPSIS

  # This only needs to be said once in your program.
  require UNIVERSAL::require;

  # Same as "require Some::Module;"
  Some::Module->require;

  # Ditto
  my $module = 'Some::Module';
  $module->require;

=head1 DESCRIPTION

If you've ever had to do this...

    eval "require $module";

to get around the bareword caveats on require(), this module is for
you.  It creates a universal require() class method that will work
with every Perl module.  So instead of doing some arcane eval() work,
you can do this:

    $module->require;

And C<use Some::Module> can be done dynamically like so:

    BEGIN {
        $module->require;
        $module->import;
    }

It doesn't save you much typing, but it'll make alot more sense to
someone who's not a ninth level Perl acolyte.

=head1 Methods

=over 4

=item B<require>

  my $return_val = $module->require;
  my $return_val = $module->require($version);

This works exactly like Perl's require, except without the bareword
restriction, and it doesn't die.  Since require() is placed in the
UNIVERSAL namespace, it will work on B<any> module.  You just have to
use UNIVERSAL::require somewhere in your code.

Should the module require fail, or not be a high enough $version, it
will simply return false and B<not die>.  The error will be in
$UNIVERSAL::require::ERROR.

=back

=head1 AUTHOR

Michael G Schwern <schwern@pobox.com>


=head1 SEE ALSO

L<UNIVERSAL::exports>, L<perlfunc/require>, 
http://dev.perl.org/rfc/253.pod

=cut


sub require {
    my($module, $want_version) = @_;

    $UNIVERSAL::require::ERROR = '';

    die("UNIVERSAL::require() can only be run as a class method")
      if ref $module; 

    die("UNIVERSAL::require() takes no or one arguments") if @_ > 2;

    # Load the module.
    my $return = eval "CORE::require $module";

    # Check for module load failure.
    if( $@ ) {
        $@ =~ s/ at .*?\n$//;
        $UNIVERSAL::require::ERROR = sprintf "$@ at %s line %d.\n", 
                                            (caller)[1,2];
        return 0;
    }

    # Module version check.  We can't just call UNIVERSAL->VERSION
    # and let it die because the file and line numbers will be wrong.
    if( @_ == 2 and !eval { $module->VERSION($want_version); 1 } ) {
        $@ =~ s/ at .*?\n$//;
        $UNIVERSAL::require::ERROR = sprintf "$@ at %s line %d\n", 
                                             (caller)[1,2];
        return 0;
    }

    return $return;
}


1;
