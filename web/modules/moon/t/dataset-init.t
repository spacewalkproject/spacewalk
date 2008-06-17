# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test;
BEGIN { plan tests => 27 };
use Data::Dumper;
use Moon::Dataset::Coordinate;
use Moon::Dataset::Function;

#check the constructor

my $ds = new Moon::Dataset::Coordinate (-interpolation => 'Linear',
			                -coords => [ [1,1], [0,0] ] );

ok(ref $ds, 'Moon::Dataset::Coordinate'); #It is what we thought it was

my $dump_1 = Data::Dumper->Dump([($ds)]);

#check alternate construction method - should be identical to previous one

$ds = new Moon::Dataset::Coordinate (-interpolation => 'Linear',
			             -x_vals => [1, 0],
				     -y_vals => [1, 0] );

my $dump_2 = Data::Dumper->Dump([($ds)]);

ok($dump_1, $dump_2);

#now check getter/setter methods

ok($ds->interpolation, 'Linear');
ok($ds->interpolation('Foo'), 'Linear'); #Shouldn't let us set to invalid value

ok(scalar (@{$ds->coords}), 2); #two points in the dataset
ok(scalar (@{$ds->coords([ [2,2], [3,-1], [-5,4], [8,3], [-1,8], [100,-9], [-2,3], [0,0] ])}), 8); #replace points in dataset


my @mins = ($ds->min_x, $ds->min_y); #minimums of first and second elements (x,y)

ok($mins[0], -5);
ok($mins[1], -9);

my @maxs = ($ds->max_x, $ds->max_y); #maximums of first and second elements (x,y)

ok($maxs[0], 100);
ok($maxs[1], 8);

ok($mins[0],$ds->coords->[0]->[0]); #the first element of the first coordinate should be the minimum

ok($maxs[0],$ds->coords->[-1]->[0]); #and the last should be the maximum


#check the value_at function

ok($ds->value_at(-5), 4);
ok($ds->value_at(-1.5), 5.5);
ok($ds->value_at(100), -9);

#now we do this wacked out database stuff

$ds->load_from_db(1000560346, 5);

my $vals = [ 1026845146, 1026845150, 1026845151, 1026845378, 1026846141, 1026846143, 1026846146 ];
my $ret = [ 6.42, 6.18, 6.12, 11.174, 20.70, 21.024, 21.51 ];

ok($ds->value_at($vals->[1]), $ret->[1]);

#this is slightly different from the last one - we are passing an arrayref instead of a single value
ok($ds->value_at($vals)->[5], $ret->[5]);


#test Moon::Dataset::Function

$ds = new Moon::Dataset::Function (-function => '$x + 1', -x_vals => [-1, -2, -3, 0, 1, 2]);

ok(ref($ds), 'Moon::Dataset::Function'); #It is what we thought it was

ok($ds->y_vals->[4],2);

ok($ds->min_x, -3);
ok($ds->max_x, 2);
ok($ds->min_y, -2);
ok($ds->max_y, 3);


#resampling

$ds = $ds->remesh(11);

ok($ds->x_vals->[3],-1.5);
ok($ds->y_vals->[3],-0.5);

$ds = $ds->remesh(6);

ok($ds->x_vals->[3], 0);
ok($ds->value_at(0), 1);

