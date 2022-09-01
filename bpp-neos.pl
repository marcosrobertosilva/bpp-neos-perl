use strict;
use warnings;

use XML::RPC;
use MIME::Base64::Perl;
use Mojo::Base -strict;
use Mojo::File;
use Archive::Any;
use XML::LibXML;

die "Please provide a valid e-mail address as the first argument." if scalar @ARGV != 1;
&run($ARGV[0]);

#-------------------------------------------------------------------------------#
sub run
{
    my $email = $_[0];
    my $model = &generate_bin_packing_problem;
    my $xml_data = &generate_xml_neos($model, $email);
    
    my ($job_number, $job_pwd, $job_status) = &solve_model_using_neos($xml_data);
    die "Unable to solve model!" if $job_status ne 'Done';

    my @res = @{ &download_results_from_neos($job_number, $job_pwd) };
    
    my $solution_status = $res[0];
    my %hVarValue = %{ $res[1] };
    print "\n- Solution Status: $solution_status\n";

    # Print the value of the variables in the console
    while ( my ($var_name, $var_value) = each (%hVarValue))
    {
        if($var_value+0 > 1e-6)
        {
            print "$var_name => $var_value\n";
        }
    }
}
#-------------------------------------------------------------------------------#
#
# Given a set of items I = {1,...,m} with weight w[i] > 0, 
# the Bin Packing Problem (BPP) is to pack the items into 
# bins of capacity c in such a way that the number of bins 
# used is minimal.
#
# Extracted from GLPK distribution (https://www.gnu.org/software/glpk/)
# Inspired in GNU MathProg version developed by Andrew Makhorin <mao@gnu.org>
sub generate_bin_packing_problem
{
    my $c = 100; # capacity of each bin
    my $m = 6;   # number of items to pack (6 items)
    
    # weight of each item.
    my %w = (1 => 50, 2 => 60, 3 => 30, 4 => 70, 5 => 50, 6 => 40);

    # - "greedy" estimation of the upper bound in terms of 
    # the number of bins needed
    my $accum = 0;
    my $n = 1; # upper bound of the number of bins needed.
    foreach my $item (keys %w)
    {
        if($accum + $w{$item} > $c)
        {
            $accum = $w{$item};
            $n++;
        } else {
            $accum += $w{$item};
        }
    }
    
    # Create objective function
    # Minimize the number of used bins
    my $model = "Minimize\n";
    $model .= " obj:";
    for(1..$n)
    {
        $model .= " + used($_)";
    }
    $model .= "\n";
    $model .= "Subject To\n";

    # Each item must be inserted in one bin
    for(my $item = 1; $item <= $m; $item++)
    {
        $model .= " one($item):";
        for(my $bin = 1; $bin <= $n; $bin++)
        {
            $model .= " + x($item,$bin)";
        }
        $model .= " = 1\n";
    }

    # Constraint:
    # Respect the capacity of each bin, i.e., the sum of
    # the weight put in each bin must be lower than or 
    # equal to the bin capacity.
    for(my $bin = 1; $bin <= $n; $bin++)
    {
        $model .= " lim($bin):";
        for(my $item = 1; $item <= $m; $item++)
        {
            $model .= " + $w{$item} x($item,$bin)";
        }
        $model .= " - $c used($bin) <= 0\n";
    }
    
    # Constraint:
    # Define the bounds for each variable, in this case, 
    # all variables are binary, with lower bound equals 
    # to 0 and upper bound equals to 1.
    $model .= "\nBounds\n";
    for(my $bin = 1; $bin <= $n; $bin++)
    {
        $model .= " 0 <= used($bin) <= 1\n";
        for(my $item = 1; $item <= $m; $item++)
        {
            $model .= " 0 <= x($item,$bin) <= 1\n";
        }
    }

    # Constraint:
    # Explicitly say to the solvers that the variables 
    # are integers, i.e., no fractional value is allowed.
    $model .= "\nGenerals\n";
    for(my $bin = 1; $bin <= $n; $bin++)
    {
        $model .= " used($bin)\n";
        for(my $item = 1; $item <= $m; $item++)
        {
            $model .= " x($item,$bin)\n";
        }
    }

    return $model;
}
#-------------------------------------------------------------------------------#
sub generate_xml_neos
{
    my $model = $_[0];
    my $email = $_[1];

    my $xml_data = <<"END_XML";
    <document>
    <category>lp</category>
    <solver>CPLEX</solver>
    <inputMethod>LP</inputMethod>
    <client><![CDATA[Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/104.0.0.0 Safari/537.36@161.69.116.21]]></client>
    <priority><![CDATA[long]]></priority>
    <email><![CDATA[$email]]></email>
    <LP><![CDATA[
    $model
    ]]>
    </LP>
    <wantsol><![CDATA[yes]]></wantsol>
    </document>
END_XML
    return $xml_data;
}
#-------------------------------------------------------------------------------#
sub download_results_from_neos
{
    my $job_number = $_[0];
    my $job_pwd = $_[1];
    my $neos = XML::RPC->new('https://neos-server.org:3333');

    # Download results form NEOS
    my $res = $neos->call('getFinalResults', ($job_number, $job_pwd) );
    my $log = decode_base64($res);
    my $log_file = Mojo::File->new("solution.log")->spurt($log);

    # get result file
    my $zip_sol = $neos->call('getOutputFile', ($job_number, $job_pwd, 'solver-output.zip'));
    $zip_sol = decode_base64($zip_sol);

    # Save local zip file with the results in xml format
    my $result_file = Mojo::File->new( "result.zip" )->spurt($zip_sol);

    # Extract the zip file with the solution
    my $archive = Archive::Any->new("result.zip")->extract;

    # parse the solution file (XML format)
    die "Solution file not found!" if not -e "soln.sol";
    my $dom = XML::LibXML->load_xml(location => "soln.sol");
    my $solution_status = $dom->findnodes('/CPLEXSolution/header/@solutionStatusString');

    # Get the value of the variables (greather than "zero")
    my %hVarValue = ();
    foreach my $vars ($dom->findnodes('//variables')) 
    {
        my $variables = map { $hVarValue{$_->getAttribute('name')} = $_->getAttribute('value'); } $vars->findnodes('./variable');
    }
    my @res = ();
    push @res, $solution_status;
    push @res, \%hVarValue;
    return \@res;
}
#-------------------------------------------------------------------------------#
sub solve_model_using_neos
{
    my $xml_job = $_[0];
    my $neos = XML::RPC->new('https://neos-server.org:3333');

    my $alive = $neos->call( 'ping', );
    die "Error: Neos Server not available!" if $alive !~ "NeosServer is alive";

    # submit job for solution
    my ($job_number, $job_pwd) = @{ $neos->call('submitJob', $xml_job) };

    # Get the job status
    my $job_status = $neos->call('getJobStatus', ($job_number, $job_pwd));
    print "Status: $job_status\n";

    # Possible status: "Done", "Running", "Waiting", "Unknown Job", or "Bad Password"
    my @valid_status = ('Done', 'Unknown Job', 'Bad Password');
    while (not grep( /^$job_status$/, @valid_status ) ) 
    {
        $job_status = $neos->call('getJobStatus', ($job_number, $job_pwd));
        print "Job: $job_number => status: $job_status\n";
    }

    return ($job_number, $job_pwd, $job_status);
}
#-------------------------------------------------------------------------------#
