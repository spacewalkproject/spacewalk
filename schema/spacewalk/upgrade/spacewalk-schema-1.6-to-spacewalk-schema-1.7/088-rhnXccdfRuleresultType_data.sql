
insert into rhnXccdfRuleresultType values (1, 'P', 'pass',
    'The target system satisfied all the conditions of the xccdf:Rule.');
insert into rhnXccdfRuleresultType values (2, 'F', 'fail',
    'The target system did not satisfy all the conditions of the xccdf:Rule');
insert into rhnXccdfRuleresultType values (3, 'E', 'error',
    'The checking engine could not complete the evaluation, therefore the status of compliance is uncertain.');
insert into rhnXccdfRuleresultType values (4, 'U', 'unknown',
    'The testing tool encountered some problem and the result is unknown.');
insert into rhnXccdfRuleresultType values (5, 'N', 'notapplicable',
    'The xccdf:Rule was not applicable to the target.');
insert into rhnXccdfRuleresultType values (6, 'K', 'notchecked',
    'The xccdf:Rule was not evaluated by the checking engine; xccdf:check was either unspecified or unsupported.');
insert into rhnXccdfRuleresultType values (7, 'S', 'notselected',
    'The xccdf:Rule was not selected in the profile.');
insert into rhnXccdfRuleresultType values (8, 'I', 'informational',
    'The xccdf:Rule was not checked; it is not a compliance category.');
insert into rhnXccdfRuleresultType values (9, 'X', 'fixed',
    'The xccdf:Rule had failed, but was then fixed by tool.');
