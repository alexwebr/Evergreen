#!/usr/bin/perl
use diagnostics;
use warnings;
use strict;
use OpenILS::Reporter::SQLBuilder;
use JSON;

my $report = {
	select => [
		{	relation=> 'circ',
			column	=> { transform => month_trunc => colname => 'checkin_time' },
			alias	=> '::PARAM4',
		},
		{	relation=> 'circ-checkin_lib-aou',
			column	=> { colname => 'shortname', transform => 'Bare'},
			alias	=> 'Library Short Name',
		},
		{	relation=> 'circ-circ_staff-au-card-ac',
			column	=> 'barcode',
			alias	=> 'User Barcode',
		},
		{	relation=> 'circ-id-mb',
			column	=> { transform => sum => colname => 'amount' },
			alias	=> '::PARAM3',
		},
	],
	from => {
		table	=> 'action.circulation',
		alias	=> 'circ',
		join	=> {
			checkin_staff => {
				table	=> 'actor.usr',
				alias	=> 'circ-circ_staff-au',
				type	=> 'inner',
				key	=> 'id',
				join	=> {
					card => {
						table	=> 'actor.card',
						alias	=> 'circ-circ_staff-au-card-ac',
						type	=> 'inner',
						key	=> 'id',
					},
				},
			},
			checkin_lib => {
				table	=> 'actor.org_unit',
				alias	=> 'circ-checkin_lib-aou',
				type	=> 'inner',
				key	=> 'id',
			},
			'id-billings' => {
				table	=> 'money.billing',
				alias	=> 'circ-id-mb',
				type	=> 'left',
				key	=> 'xact',
			},
		},
	},
	where => [
		{	relation	=> 'circ-checkin_lib-aou',
			column		=> 'id',
			condition	=> { 'in' => '::PARAM1' },
		},
		{	relation	=> 'circ',
			column		=> { transform => month_trunc => colname => 'checkin_time' },
			condition	=> { 'in' => '::PARAM2' },
		},
		{	relation	=> 'circ-id-mb',
			column		=> 'voided',
			condition	=> { '=' => '::PARAM7' },
		},
	],
	having => [],
	order_by => [
		{	relation=> 'circ-checkin_lib-aou',
			column	=> { colname => 'shortname', transform => 'Bare' },
		},
		{	relation=> 'circ',
			column	=> { transform => month_trunc => colname => 'checkin_time' },
			direction => 'descending'
		},
		{	relation=> 'circ-circ_staff-au-card-ac',
			column	=> 'barcode',
		},
	],
	pivot_default => 0,
	pivot_data => 4,
	pivot_label => 2,
};

$select = JSON->JSON2perl('{"select":[{"relation":"b312819df8fe889b50f70ea9fa054e72","path":"au-home_ou-aou-shortname","alias":"ILS User:Home Library:Short (Policy) Name","column":{"transform":"Bare","colname":"shortname"}},{"relation":"80bfa74cd4909b585f6187fe8f8591c5","path":"au-survey_responses-asvr-survey-asv-name","alias":"ILS User:Survey Responses:survey:name","column":{"transform":"Bare","colname":"name"}},{"relation":"8a6cb366f41b2b8186df7c7749ff41ba","path":"au-survey_responses-asvr-answer-asva-answer","alias":"ILS User:Survey Responses:answer:Answer Text","column":{"transform":"Bare","colname":"answer"}},{"relation":"8bcc25c96aa5a71f7a76309077753e67","path":"au-id","alias":"count","column":{"transform":"count","colname":"id"}}],"from":{"table":"actor.usr","path":"au","alias":"8bcc25c96aa5a71f7a76309077753e67","join":{"id-survey_responses":{"key":"usr","type":"left","table":"action.survey_response","path":"au-survey_responses-asvr","alias":"cab1b47d26fa649f9a795d191bac0642","join":{"survey":{"key":"id","table":"action.survey","path":"au-survey_responses-asvr-survey-asv","alias":"80bfa74cd4909b585f6187fe8f8591c5"},"answer":{"key":"id","table":"action.survey_answer","path":"au-survey_responses-asvr-answer-asva","alias":"8a6cb366f41b2b8186df7c7749ff41ba"}}},"home_ou":{"key":"id","table":"actor.org_unit","path":"au-home_ou-aou","alias":"b312819df8fe889b50f70ea9fa054e72"}}},"where":[{"relation":"80bfa74cd4909b585f6187fe8f8591c5","path":"au-survey_responses-asvr-survey-asv-id","column":{"transform":"Bare","colname":"id"},"condition":{"in":"::P0"}},{"relation":"b312819df8fe889b50f70ea9fa054e72","path":"au-home_ou-aou-id","column":{"transform":"Bare","colname":"id"},"condition":{"in":"::P1"}}],"having":[],"order_by":[]}');

my $params = {
	PARAM1 => [ 18, 19, 20, 21, 22, 23 ],
	#PARAM2 => ['2006-07','2006-08','2006-09'],
	PARAM2 => [{transform => 'relative_month', params => [-2]},{transform => 'relative_month', params => [-3]}],
	PARAM3 => 'Billed Amount',
	PARAM4 => 'Checkin Date',
	PARAM5 => [{ transform => 'Bare', params => [10] },{ transform => 'Bare', params => [100] }],
	PARAM6 => [ 1, 4 ],
	PARAM7 => 'f',
};

$params = JSON->JSON2perl('{"P0":["1"],"P1":["1","17","18","20","19","22","24","25","27","21","29","26","28","23","30","226","227","229","230","228","221","222","130","131","132","231","232","233","234","235","223","224","225","135","137","136","138","139","140","141","277","280","279","283","281","282","284","278","133","134","262","263","265","266","264","268","267","43","44","45","46","47","48","285","286","287","296","288","289","299","290","291","292","293","294","295","298","297","300","301","302","31","32","33","34","41","42","121","122","123","125","129","126","124","127","128","168","169","170","171","172","173","194","195","151","154","155","152","153","164","165","167","166","236","237","238","240","239","269","270","271","272","273","274","275","276","118","119","120","243","251","256","244","245","246","247","248","249","250","252","253","255","257","254","258","259","260","261","10","12","11","13","15","14","16","108","109","110","111","112","113","241","242","156","157","158","160","162","163","159","161","303","304","307","306","305","308","310","309","311","207","211","208","209","210","88","89","91","90","212","213","218","215","214","217","216","219","220","70","72","71","74","73","75","76","77","114","115","116","117","196","197","201","199","200","204","202","203","206","198","205","100","101","102","103","104","105","106","107","68","69","98","99","35","38","37","36","39","40","142","143","144","145","146","147","148","149","150","92","93","94","95","96","97","188","189","190","191","192","193","61","62","67","63","64","65","66","78","79","80","81","82","85","84","86","83","87","58","59","60","49","56","50","51","52","54","53","55","57","174","182","175","177","179","180","183","181","184","185","186","187","176","178"]}');

my $r = OpenILS::Reporter::SQLBuilder->new;

$r->register_params( $params );
my $rs = $r->parse_report( $report );
$rs->relative_time('2006-10-01T00:00:00-4');

print "Column Labels: " . join(', ', $rs->column_label_list) . "\n";
print $rs->toSQL;

print "\n\n";

print "SQL group by list: ".join(',',$rs->group_by_list)."\n";
print "Perl group by list: ".join(',',$rs->group_by_list(0))."\n";

