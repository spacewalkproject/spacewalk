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

def index_view(request):
    t = get_template("index.html")
    html = t.render(Context())
    return HttpResponse(html)


def list_reports(request):
    
    t = get_template("list_reports.html")
    
    # Open & parse Configuration file
    config_dir = "/usr/share/telemetry/config/"
    
    files = os.listdir(config_dir)
    
    reports = []
    
    for file in files:
        
        parameters = None
        
        # Open each file and parse
        f = open(os.path.join(config_dir, file), 'r')
        
        parameters =  yaml.load(f)
        
        reports.append({'report_name': parameters['Name'], 'report_config': file})
        
        f.close()
        
    html = t.render(Context({'reports': reports}))
    
    return HttpResponse(html)


def report_details(request):
    
    # Open & parse Configuration file
    config_dir = "/usr/share/telemetry/config"
    
    parameters = None
        
    f = open(os.path.join(config_dir, request.GET['config']), 'r')

    parameters = yaml.load(f)
    
    c = CronTab()
    crons = c.find_command(parameters['Report_Script'])
    data = []
    
    for cron in crons:
        data.append(cron.render().split('# '))
        
    t = get_template("report_details.html")
    
    html = t.render(Context({'parameters': parameters, 'config': request.GET['config'], 'crons': data}))
        
    f.close()
    
    return HttpResponse(html)

def report_results(request):
    
    scripts_dir = "/usr/share/telemetry/scripts"
    config_dir = "/usr/share/telemetry/config"
    
    f = open(os.path.join(config_dir, request.POST['config']), 'r')
    
    parameters = yaml.load(f)
    
    report_config = request.POST['config']
    report_script = parameters['Report_Script']
    username = request.POST['username']
    password = request.POST['password']
    type = request.POST['type']
    
    command = "%s %s %s %s %s" % (os.path.join(scripts_dir, report_script), report_config, type, username, password)
    
    # Append Criteria
    if (parameters.has_key('Criteria')):
        for criterion in parameters['Criteria']:
            if (request.POST.has_key(criterion['label'])):
                command = command + " " + request.POST[criterion['label']]
    
    # Redirect if schedule button was clicked...
    if (request.POST.has_key('schedule') and request.POST['schedule']):
        
        t = CronTab()
        
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
        
        t = CronTab()
        print unicode(t.render())
        
        crons = t.find_command(report_script)
        
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

    os.chdir(parameters['Report_Dir'])
    ext = "%s*.%s" % (str(parameters['Report_Name']), str(type)) 
    l = [(os.stat(i).st_mtime, i) for i in glob.glob(ext)]
    l.sort()
    files = [i[1] for i in l]
    files.reverse()
     
    html = t.render(Context({'parameters': parameters, 'type': type, 'files': files, 'time': timeTaken}))
        
    f.close()

    return HttpResponse(html)

def report_schedule(request):
    
    print request.session
    
    return HttpResponse("Schedule Page")

    