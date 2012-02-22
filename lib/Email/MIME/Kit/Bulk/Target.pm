package Email::MIME::Kit::Bulk::Target;
# ABSTRACT: Destination for an Email::MIME::Kit::Bulk email

=head1 SYNOPSIS

    use Email::MIME::Kit::Bulk::Target;

    my $target = Email::MIME::Kit::Bulk::Target->new(
        to => 'someone@somewhere.com',
        cc =>  [ 'someone_else@somewhere.com' ],
        bcc => [ 'sneaky@somewhere.com' ],
        from => 'me@somewhere.com',
        language => 'en',
        template_params => {
            greetings => 'Hi',
        },
        extra_attachments => [ 'foo.pdf' ] 
    );
    
    Email::MIME::Kit::Bulk->new(
        kit => '/path/to/mime/kit',
        processes => 5,
        targets => [ $target ],
    )->send;

=head1 DESCRIPTION

A L<Email::MIME::Kit::Bulk> object will produce one email for every
C<Email::MIME::Kit::Bulk::Target> object it is given. Each target object
defines the recipients of the email, and can also be take 
attachments, specific I<From> address and custom parameters for the MIME kit 
template. 

=head1 METHODS

=head2 new( %args )

Constructor.

=head3 Arguments

=over

=item to => $email_address

C<To> Email address. Can be a string or a L<MooseX::Types::Email::EmailAddress> object.

Required.

=item cc => \@email_addresses

C<Cc> Email addressses. Array ref of L<MooseX::Types::Email::EmailAddress> objects.

=item bcc => \@email_addresses

C<Bcc> Email addressses. Array ref of L<MooseX::Types::Email::EmailAddress> objects.

=item from => $email_address

Address to use for the C<From> originator. 
Must be a L<MooseX::Types::Email::EmailAddress> object.

=item language => $lang

Language to use for this target.

=item template_params => \%params

Parameters to be passed to the L<Email::MIME::Kit> template.

=item extra_attachments => \@attachments

Attachments to add to the email for this target.

=back

=cut

use strict;
use warnings;

use Moose;
use namespace::autoclean;

use MooseX::Types::Email;

=head2 to()

Returns the L<MooseX::Types::Email::EmailAddress> object 
for the C<To> recipient.

=cut

has to => (
    is       => 'ro',
    isa      => 'MooseX::Types::Email::EmailAddress',
    required => 1,
);

=head2 cc()

    my @cc = $target->cc;

Returns the list of L<MooseX::Types::Email::EmailAddress> objects 
for the C<Cc> recipients.

=cut

has cc => (
    traits  => ['Array'],
    isa     => 'ArrayRef[MooseX::Types::Email::EmailAddress]',
    default => sub { [] },
    handles => {
        cc => 'elements',
    },
);

=head2 bcc()

    my @bcc = $target->bcc;

Returns the list of L<MooseX::Types::Email::EmailAddress> objects 
for the C<Bcc> recipients.

=cut

has bcc => (
    traits  => ['Array'],
    isa     => 'ArrayRef[MooseX::Types::Email::EmailAddress]',
    default => sub { [] },
    handles => {
        bcc => 'elements',
    },
);

=head2 from()

    my $from = $target->from;

Returns the  L<MooseX::Types::Email::EmailAddress> object
for the C<From> originator.

=cut

has from => (
    is  => 'ro',
    isa => 'MooseX::Types::Email::EmailAddress',
);

=head2 language()

    my $lang = $target->language;

Returns the  language set for the target.

=head2 has_language()

Returns true if a language was set for the target.

=cut

has language => (
    is        => 'ro',
    isa       => 'Str',
    predicate => 'has_language',
);

=head2 template_params()

Returns the hash ref of the parameters that will be passed to the
L<Email::MIME::Kit> template.

=cut

has template_params => (
    is      => 'ro',
    isa     => 'HashRef',
    default => sub { {} },
);

=head2 extra_attachments()

Returns the list of extra attachments that will be added
to the email for this target.

=cut

has extra_attachments => (
    traits  => ['Array'],
    isa     => 'ArrayRef[Str|ArrayRef[Str]]',
    default => sub { [] },
    handles => {
        extra_attachments => 'elements',
    },
);

=head2 recipients 

Returns all the recipients (I<To>, I<Cc> and I<Bcc> combined) of the email.

=cut

sub recipients {
    my $self = shift;

    # TODO remove dupes?
    return (
        $self->to,
        $self->cc,
        $self->bcc,
    );
}

__PACKAGE__->meta->make_immutable;

1;
