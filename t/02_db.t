use strict;
use warnings;
use Test::More;

BEGIN { use_ok 'Soffritto::Web' }

my $web = Soffritto::Web->new(
    dsn => ['dbi:SQLite:','','']
);
$web->to_app;

isa_ok $web->db, 'Soffritto::DB';
isa_ok $web->db->dbh, 'DBI::db';
my $sql = <<END;
create table dbtest(
    id int,
    subject text,
    body text
)
END
ok $web->db->dbh->do($sql);
my $data = {
    id => 1,
    subject => 'hello',
    body => 'world!',
};
ok $web->db->insert('dbtest', $data);
is_deeply $web->db->find('dbtest', '*', {id => 1}), $data;
is_deeply $web->db->select('dbtest', '*'), [$data];
my $update = { body => 'goodbye!' };
ok $web->db->update('dbtest', $update, {id => 1});
is_deeply $web->db->find('dbtest', '*', {id => 1}), {%$data, %$update};
is_deeply $web->db->find('dbtest', 'body', {id => 1}), $update;
ok $web->db->delete('dbtest', {id => 1});
is_deeply $web->db->find('dbtest', '*', {id => 1}), undef;
is_deeply $web->db->select('dbtest', '*'), [];

done_testing;
