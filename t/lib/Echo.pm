package Echo;
sub Echo::say {
    my $cb = pop;
    my ($class, @args) = @_;
    $cb->($class, @args);
}
1;
