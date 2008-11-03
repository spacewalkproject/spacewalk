from django.conf.urls.defaults import *
from telemetry_web.views import *

urlpatterns = patterns('',
    (r'^reports/$', list_reports),
    (r'^reports/reportdetails/$', report_details),
    (r'^reports/reportdetails/$', report_details),
    (r'^reports/reportresults$', report_results),
    (r'^reports/reportresults$', report_results),
    (r'', index_view),
)
