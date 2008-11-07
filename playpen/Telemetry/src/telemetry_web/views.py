from django.template.loader import get_template
from django.template import Context
from django.http import HttpResponse
from django.http import HttpResponsePermanentRedirect
from crontab import CronTab
import yaml
import datetime
import time
import os
import glob
import sys
import uuid
import telemetry

def index_view(request):
    t = get_template("index.html")
    html = t.render(Context())
    return HttpResponse(html)


def list_reports(request):
    
    t = get_template("list_reports.html")
        
    html = t.render(Context({'reports': telemetry.getReports()}))
    
    return HttpResponse(html)


def report_details(request):
    
    report = telemetry.Report(request.GET['config'])
    
    c = CronTab(user=telemetry.getConfig()['cron_user'], sudo=True)
    crons = c.find_command(report.script)
    data = []
    
    for cron in crons:
        data.append(cron.render().split('# '))
        
    t = get_template("report_details.html")
    
    html = t.render(Context({'report': report, 'crons': data}))
    
    return HttpResponse(html)

def report_results(request):
    
    config = telemetry.getConfig()
    scripts_dir = telemetry.USER_TELEMETRY_DIR + "scripts"
    config_dir = telemetry.USER_TELEMETRY_DIR + "config"
    
    report = telemetry.Report(request.POST['config'])
    
    report_config = request.POST['config']
    username = request.POST['username']
    password = request.POST['password']
    type = request.POST['type']
    
    command = "%s %s %s %s %s" % (os.path.join(scripts_dir, report.script), report_config, type, username, password)
    
    # Append Criteria
    for criterion in report.criteria:
        if (request.POST.has_key(criterion['label'])):
            command = command + " " + request.POST[criterion['label']]
    
    # Redirect if schedule button was clicked...
    if (request.POST.has_key('schedule') and request.POST['schedule']):
        
        t = CronTab(user=config['cron_user'], sudo=True)
        
        try: 
            n = t.new(command=command,comment=str(uuid.uuid4()))
            n.minute().on(int(request.POST['minute']))
            n.hour().on(int(request.POST['hour']))
                        
            #print unicode(t.render())
            
            t.write()
            
        except (ValueError):
            pass
        
        
        url = "../reportdetails?config=%s" % report_config
        
        return HttpResponsePermanentRedirect(url)
    
    if (request.POST.has_key('delete') and request.POST['delete']):
        
        t = CronTab(user=config['cron_user'], sudo=True)
        print unicode(t.render())
        
        crons = t.find_command(report.script)
        
        for cron in crons:
            if (cron.meta() == request.POST['delete']):
                t.remove(cron)     
        t.write()
                
        url = "../reportdetails?config=%s" % report_config
        return HttpResponsePermanentRedirect(url)
    
    t1 = time.time()
    rc = os.system(command)
    t2 = time.time()
    timeTaken = t2 - t1

    t = get_template("report_results.html")

    os.chdir(config['report_directory'])
    ext = "%s*.%s" % (str(report.prefix), str(type)) 
    l = [(os.stat(i).st_mtime, i) for i in glob.glob(ext)]
    l.sort()
    files = [i[1] for i in l]
    files.reverse()
     
    html = t.render(Context({'type': type, 'files': files, 'time': timeTaken, 'config': config}))

    return HttpResponse(html)

    