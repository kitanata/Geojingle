# Create your views here.
from datetime import datetime
import json
from django.http import HttpResponse
from django.shortcuts import render_to_response, get_object_or_404
from django.template.context import RequestContext
from django.utils import simplejson
from cloud.models import CloudProjectStorageItem


def project_list(request):
    project_items = CloudProjectStorageItem.objects.filter(user=request.user)
    project_names = map(lambda project: str(project.name), project_items)
    project_dates = map(lambda project: str(project.last_modified), project_items)
    list_data = dict(zip(project_names, project_dates))

    return render_to_response('json/base.json', {'json': json.dumps(list_data)}, context_instance=RequestContext(request))

def project(request, project_name):
    if request.method ==  'POST':
        return save_project(request, project_name)
    elif request.method == 'GET' or request.method == 'HEAD':
        return open_project(request, project_name)

def save_project(request, project_name):
    saveData = json.loads(request.raw_post_data)
    print("Save Data ", saveData)
    print("Dump Data ", json.dumps(saveData))

    try:
        curProject = CloudProjectStorageItem.objects.get(user=request.user, name=project_name)
        curProject.last_modified = datetime.now()
        curProject.saved_data = json.dumps(saveData)
        curProject.save()
    except CloudProjectStorageItem.DoesNotExist:
        newProject = CloudProjectStorageItem()
        newProject.last_modified = datetime.now()
        newProject.user = request.user
        newProject.saved_data = json.dumps(saveData)
        newProject.name = project_name
        newProject.save()
    except Exception as e:
        print(str(e))

    return HttpResponse(mimetype='application/json')

def open_project(request, project_name):
    print("user is " + str(request.user))
    print("project_name is " + str(project_name))

    project = get_object_or_404(CloudProjectStorageItem, user=request.user, name=project_name)
    
    return render_to_response('json/base.json', {'json': project.saved_data}, context_instance=RequestContext(request))