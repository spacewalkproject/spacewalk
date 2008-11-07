from django.conf.urls.defaults import *
from telemetry_web.views import *

urlpatterns = patterns('',
    (r'^telemetry/reports[/]$', list_reports),
    (r'^telemetry/reports/reportdetails[/]$', report_details),
    (r'^telemetry/reports/reportresults[/]$', report_results),
    (r'^telemetry[/]$', index_view)
)
