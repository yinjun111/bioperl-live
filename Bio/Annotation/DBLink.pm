# $Id$
#
# BioPerl module for Bio::Annotation::Link
#
# Cared for by Ewan Birney <birney@ebi.ac.uk>
#
# Copyright Ewan Birney
#
# You may distribute this module under the same terms as perl itself

# POD documentation - main docs before the code

=head1 NAME

Bio::Annotation::DBLink - DESCRIPTION of Object

=head1 SYNOPSIS

   $link1 = new Bio::Annotation::DBLink(-database => 'TSC',
                                        -primary_id => 'TSC0000030'
					);

   #or 

   $link2 = new Bio::Annotation::DBLink();
   $link2->database('dbSNP');
   $link2->primary_id('2367');

   # DBLink is-a Bio::AnnotationI object, can be added to annotation
   # collections, e.g. the one on features or seqs
   $feat->annotation->add_Annotation('dblink', $link2);


=head1 DESCRIPTION

Provides an object which represents a link from one object to something
in another database without prescribing what is in the other database

=head1 AUTHOR - Ewan Birney

Ewan Birney - birney@ebi.ac.uk

=head1 APPENDIX

The rest of the documentation details each of the object
methods. Internal methods are usually preceded with a _

=cut


# Let the code begin...

package Bio::Annotation::DBLink;
use vars qw(@ISA);
use strict;

use Bio::Root::Root;
use Bio::AnnotationI;
use Bio::IdentifiableI;

@ISA = qw(Bio::Root::Root Bio::AnnotationI Bio::IdentifiableI);


sub new {
  my($class,@args) = @_;

  my $self = $class->SUPER::new(@args);

  my ($database, $primary_id, $optional_id, $comment, $tag, $ns, $auth, $v) =
      $self->_rearrange([qw(DATABASE
			    PRIMARY_ID
			    OPTIONAL_ID
			    COMMENT
			    TAGNAME
			    NAMESPACE
			    AUTHORITY
			    VERSION
			    )], @args);
  
  $database    && $self->database($database);
  $primary_id  && $self->primary_id($primary_id);
  $optional_id && $self->optional_id($optional_id);
  $comment     && $self->comment($comment);
  $tag         && $self->tagname($tag);
  # Bio::IdentifiableI parameters:
  $ns          && $self->namespace($ns); # this will override $database
  $auth        && $self->authority($auth);
  defined($v)  && $self->version($v);

  return $self;
}

=head1 AnnotationI implementing functions

=cut


=head2 as_text

 Title   : as_text
 Usage   :
 Function:
 Example :
 Returns : 
 Args    :


=cut

sub as_text{
   my ($self) = @_;

   return "Direct database link to ".$self->primary_id." in database ".$self->database;
}

=head2 hash_tree

 Title   : hash_tree
 Usage   :
 Function:
 Example :
 Returns : 
 Args    :


=cut

sub hash_tree{
   my ($self) = @_;
   
   my $h = {};
   $h->{'database'}   = $self->database;
   $h->{'primary_id'} = $self->primary_id;
   if( defined $self->optional_id ) {
       $h->{'optional_id'} = $self->optional_id;
   }
   if( defined $self->comment ) {
       # we know that comments have hash_tree methods
       $h->{'comment'} = $self->comment;
   }

   return $h;
}

=head2 tagname

 Title   : tagname
 Usage   : $obj->tagname($newval)
 Function: Get/set the tagname for this annotation value.

           Setting this is optional. If set, it obviates the need to
           provide a tag to Bio::AnnotationCollectionI when adding
           this object. When obtaining an AnnotationI object from the
           collection, the collection will set the value to the tag
           under which it was stored unless the object has a tag
           stored already.

 Example : 
 Returns : value of tagname (a scalar)
 Args    : new value (a scalar, optional)


=cut

sub tagname{
    my ($self,$value) = @_;
    if( defined $value) {
	$self->{'tagname'} = $value;
    }
    return $self->{'tagname'};
}

=head1 Specific accessors for DBLinks

=cut

=head2 database

 Title   : database
 Usage   : $self->database($newval)
 Function: set/get on the database string. Databases are just
           a string here which can then be interpreted elsewhere
 Example : 
 Returns : value of database
 Args    : newvalue (optional)

=cut

sub database{
    my $self = shift;

    return $self->{'database'} = shift if @_;
    return $self->{'database'};
}

=head2 primary_id

 Title   : primary_id
 Usage   : $self->primary_id($newval)
 Function: set/get on the primary id (a string)
           The primary id is the main identifier used for this object in 
           the database. Good examples would be accession numbers. The id
           is meant to be the main, stable identifier for this object
 Example : 
 Returns : value of primary_id
 Args    : newvalue (optional)

=cut

sub primary_id{
    my $self = shift;

    return $self->{'primary_id'} = shift if @_;
    return $self->{'primary_id'};
}

=head2 optional_id

 Title   : optional_id
 Usage   : $self->optional_id($newval)
 Function: get/set for the optional_id (a string)

           optional id is a slot for people to use as they wish. The
           main issue is that some databases do not have a clean
           single string identifier scheme. It is hoped that the
           primary_id can behave like a reasonably sane "single string
           identifier" of objects, and people can use/abuse optional
           ids to their heart's content to provide precise mappings.

 Example : 
 Returns : value of optional_id
 Args    : newvalue (optional)

=cut

#'

sub optional_id{
    my $self = shift;

    return $self->{'optional_id'} = shift if @_;
    return $self->{'optional_id'};
}

=head2 comment

 Title   : comment
 Usage   : $self->comment($newval)
 Function: get/set of comments (comment object)
           Sets or gets comments of this dblink, which is sometimes relevant
 Example : 
 Returns : value of comment (Bio::Annotation::Comment)
 Args    : newvalue (optional)

=cut

sub comment{
    my $self = shift;

    return $self->{'comment'} = shift if @_;
    return $self->{'comment'};
}

=head1 Methods for Bio::IdentifiableI compliance

=head2 object_id

 Title   : object_id
 Usage   : $string    = $obj->object_id()
 Function: a string which represents the stable primary identifier
           in this namespace of this object. For DNA sequences this
           is its accession_number, similarly for protein sequences

           This is aliased to primary_id().
 Returns : A scalar


=cut

sub object_id {
    return shift->primary_id(@_);
}

=head2 version

 Title   : version
 Usage   : $version    = $obj->version()
 Function: a number which differentiates between versions of
           the same object. Higher numbers are considered to be
           later and more relevant, but a single object described
           the same identifier should represent the same concept

 Returns : A number

=cut

sub version{
    my $self = shift;

    return $self->{'version'} = shift if @_;
    return $self->{'version'};
}

=head2 authority

 Title   : authority
 Usage   : $authority    = $obj->authority()
 Function: a string which represents the organisation which
           granted the namespace, written as the DNS name for  
           organisation (eg, wormbase.org)

 Returns : A scalar

=cut

sub authority{
    my $self = shift;

    return $self->{'authority'} = shift if @_;
    return $self->{'authority'};
}

=head2 namespace

 Title   : namespace
 Usage   : $string    = $obj->namespace()
 Function: A string representing the name space this identifier
           is valid in, often the database name or the name
           describing the collection 

           For DBLink this is the same as database().
 Returns : A scalar


=cut

sub namespace{
    return shift->database(@_);
}

1;
